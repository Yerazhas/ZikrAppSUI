//
//  ZikrTapViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 17.01.2023.
//

import Foundation
import Factory
import RealmSwift
import SwiftUI

typealias ZikrTapOut = (ZikrTapOutCmd) -> Void
enum ZikrTapOutCmd {
    case close
    case delete(() -> Void)
    case openPaywall
}

final class ZikrTapViewModel: ObservableObject, Hapticable {
    @Published private(set) var count: Int = 0
    private var internalCount: Int = 0
    @Published private(set) var totalCount: Int
    @Published var dailyAmount: String = ""
    @Published var dailyAmountStatusString: String = ""
    @Published var isTapViewExpanded: Bool = false
    @Injected(Container.analyticsService) private var analyticsService
    @Injected(Container.subscriptionSyncService) private var subscriptionService
    @Injected(Container.appStatsService) private var appStatsService
    private let zikrService = ZikrService()
    let zikr: Zikr
    private let out: ZikrTapOut

    init(zikr: Zikr, out: @escaping ZikrTapOut) {
        self.zikr = zikr
        self.out = out
        totalCount = zikr.totalDoneCount
        count = zikr.currentDoneCount
//        NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: .main) { _ in
//            self.willDisappear()
//        }
        self.makeStatusString()
    }

    func zikrDidTap() {
        hapticLight()
        count += 1
        internalCount += 1
        totalCount += 1
        zikrService.updateZikrTotalCount(
            type: zikr.type,
            id: zikr.id,
            currentlyDoneCount: count,
            internalDoneCount: 1,
            totallyDoneCount: totalCount
        )
        analyticsService.trackCloseZikr(zikr: zikr, count: internalCount)
        makeStatusString()
    }

    func reset() {
        hapticStrong()
        count = 0
        internalCount = 0
        zikrService.updateZikrTotalCount(
            type: zikr.type,
            id: zikr.id,
            currentlyDoneCount: count,
            internalDoneCount: internalCount,
            totallyDoneCount: totalCount
        )
    }

    func openPaywallIfNeeded() {
        if subscriptionService.isSubscrtibed || appStatsService.canExpand {
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
        analyticsService.trackOpenZikr(zikr: zikr)
    }

    func willDisappear() {
        hapticLight()
//        zikrService.updateZikrTotalCount(
//            type: zikr.type,
//            id: zikr.id,
//            currentlyDoneCount: count,
//            internalDoneCount: internalCount,
//            totallyDoneCount: totalCount
//        )
        analyticsService.trackCloseZikr(zikr: zikr, count: internalCount)
        out(.close)
    }

    func deleteZikr() {
        hapticLight()
        out(.delete(delete))
    }

    func setAmount() {
        let realm = try! Realm()
        guard let amount = Int(dailyAmount) else {
            return
        }
        if zikr.type == .zikr {
            guard let zikr = realm.objects(Zikr.self).where({ $0.id == zikr.id }).first else {
                return
            }
            try! realm.write {
                zikr.dailyTargetAmountAmount = amount
            }
        } else if zikr.type == .dua {
            guard let dua = realm.objects(Dua.self).where({ $0.id == zikr.id }).first else { return }
            try! realm.write {
                dua.dailyTargetAmountAmount = amount
            }
        }
        makeStatusString()
    }

    private func delete() {
        let realm = try! Realm()
        do {
            if zikr.type == .zikr {
                guard let zikr = realm.objects(Zikr.self).where({ $0.id == zikr.id }).first else { return }
                try realm.write {
                    realm.delete(zikr)
                    out(.close)
                }
            } else if zikr.type == .dua {
                guard let dua = realm.objects(Dua.self).where({ $0.id == zikr.id }).first else { return }
                try realm.write {
                    realm.delete(dua)
                    out(.close)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    private func makeStatusString() {
        if zikr.dailyTargetAmountAmount == 0 {
            dailyAmountStatusString = ""
        } else {
            let realm = try! Realm()
            guard let tempZikr = realm.objects(Zikr.self).first(where: { $0.id == zikr.id }) else { return }
            let progress = tempZikr.getCurrentProgress(for: .init())
            let currentAmount = (progress?.0 ?? 0)
            let targetAmount = progress?.1 ?? 0
            let remainingAmount = targetAmount - currentAmount
            dailyAmountStatusString = remainingAmount <= 0 ? "Daily amount done!" : "Remaining: \(remainingAmount)"
        }
    }
}
