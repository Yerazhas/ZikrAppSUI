//
//  WirdTapViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 18.01.2023.
//

import Foundation
import RealmSwift
import Haptica
import Factory
import SwiftUI

struct TargetedZikr: Hashable {
    let zikr: Zikr
    let targetAmount: Int

    func hash(into hasher: inout Hasher) {
        hasher.combine(zikr.id)
    }
}

typealias WirdTapOut = (WirdTapOutCmd) -> Void
enum WirdTapOutCmd {
    case close
    case delete(() -> Void)
    case openPaywall
}

final class WirdTapViewModel: ObservableObject, Hapticable {
    @Published var currentIndex: Int = 0 {
        didSet {
            currentTargetedZikr = targetedZikrs[currentIndex]
        }
    }
    @Published private(set) var count: Int = 0
    @Injected(Container.analyticsService) private var analyticsService
    @Injected(Container.subscriptionSyncService) private var subscriptionService
    @Injected(Container.appStatsService) private var appStatsService
    let wird: Wird
    private var totalDoneCount: Int
    private var finishedCount: Int = 0

    @Published var dailyAmount: String = ""
    @Published var dailyAmountStatusString: String = ""

    private var isFinished: Bool = false
    private let zikrService = ZikrService()
    private let out: WirdTapOut
    let targetedZikrs: [TargetedZikr]

    @Published private(set) var currentTargetedZikr: TargetedZikr
    @Published var isTapViewExpanded: Bool = false

    init(wird: Wird, out: @escaping WirdTapOut) {
        self.wird = wird
        self.totalDoneCount = wird.totalDoneCount
        self.out = out
        let realm = try! Realm()
        let zikrs = realm.objects(Zikr.self)
        let duas = realm.objects(Dua.self)
        var tempTargetedZikrs = [TargetedZikr]()
        for zikr in wird.zikrs {
            if zikr.type == .zikr {
                if let tempZikr = zikrs.first(where: { $0.id == zikr.zikrId }) {
                    tempTargetedZikrs.append(.init(zikr: tempZikr, targetAmount: zikr.targetCount))
                }
            } else if zikr.type == .dua {
                if let tempDua = duas.first(where: { $0.id == zikr.zikrId }) {
                    tempTargetedZikrs.append(.init(zikr: tempDua, targetAmount: zikr.targetCount))
                }
            }
        }
        targetedZikrs = tempTargetedZikrs
        currentTargetedZikr = targetedZikrs[0]
        self.makeStatusString()
    }

    func zikrDidTap() {
        if count < currentTargetedZikr.targetAmount {
            hapticLight()
            count += 1
        }

        if currentIndex == self.targetedZikrs.count - 1 && count == currentTargetedZikr.targetAmount {
            hapticStrong()
            if !isFinished {
                zikrService.updateZikrTotalCount(
                    type: .wird,
                    id: wird.id,
                    isSubscribed: subscriptionService.isSubscribed || isFreeProgressTrackingAvailable(),
                    currentlyDoneCount: 1,
                    internalDoneCount: 0, // doesnt affect anything
                    totallyDoneCount: totalDoneCount + 1
                )
                isFinished = true
                finishedCount += 1
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if self.count == self.currentTargetedZikr.targetAmount && self.currentIndex < self.targetedZikrs.count - 1 {
                self.currentIndex += 1
                self.hapticStrong()
                self.count = 0
            }
        }
        makeStatusString()
    }

    func reset() {
        isFinished = false
        totalDoneCount += 1
        currentIndex = 0
        hapticStrong()
        count = 0
    }

    func expandIfPossible() {
        if subscriptionService.isSubscribed || appStatsService.canExpand {
            hapticLight()
            appStatsService.didExpand()
            withAnimation(.linear(duration: 0.2)) {
                isTapViewExpanded.toggle()
            }
        } else {
            hapticStrong()
            out(.openPaywall)
        }
    }

    func onAppear() {
        analyticsService.trackOpenWird(wird: wird)
    }

    func willDisappear() {
        hapticLight()
        analyticsService.trackCloseWird(wird: wird, count: isFinished ? totalDoneCount + 1 : totalDoneCount)
        out(.close)
    }

    func deleteWird() {
        hapticLight()
        out(.delete(delete))
    }

    func setAmount() {
        let realm = try! Realm()
        guard let amount = Int(dailyAmount) else {
            return
        }
        guard let wird = realm.objects(Wird.self).where({ $0.id == wird.id }).first else {
            return
        }
        try! realm.write {
            wird.dailyTargetAmountAmount = amount
        }
        makeStatusString()
    }

    private func isFreeProgressTrackingAvailable() -> Bool {
        let realm = try! Realm()
        let progressesCount = realm.objects(DailyZikrProgress.self).where { $0.targetAmount == $0.amountDone }.count
        return progressesCount < 12
    }

    private func delete() {
        let realm = try! Realm()
        do {
            guard let wird = realm.objects(Wird.self).where({ $0.id == wird.id }).first else { return }
            try realm.write {
                realm.delete(wird)
                out(.close)
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    private func makeStatusString() {
        if wird.dailyTargetAmountAmount == 0 {
            dailyAmountStatusString = ""
        } else {
            let realm = try! Realm()
            guard let tempWird = realm.objects(Wird.self).first(where: { $0.id == wird.id }) else { return }
            let progress = tempWird.getCurrentProgress(for: .init())
            let currentAmount = (progress?.0 ?? 0)
            let targetAmount = progress?.1 ?? 0
            let remainingAmount = targetAmount - currentAmount
            dailyAmountStatusString = remainingAmount <= 0 ? "Daily amount done!" : "Remaining: \(remainingAmount)"
        }
    }
}

protocol Hapticable {
    func hapticLight()
    func hapticStrong()
}

extension Hapticable {
    func hapticLight() {
        Haptic.impact(.medium).generate()
    }

    func hapticStrong() {
        Haptic.notification(.error).generate()
    }
}
