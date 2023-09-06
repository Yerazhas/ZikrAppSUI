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
import AudioToolbox

typealias ZikrTapOut = (ZikrTapOutCmd) -> Void
enum ZikrTapOutCmd {
    case close
    case delete(() -> Void)
    case openPaywall
}

@MainActor
final class ZikrTapViewModel: ObservableObject, Hapticable {
    @Published private(set) var count: Int = 0
    private var internalCount: Int = 0
    @Published private(set) var totalCount: Int
    @Published var dailyAmount: String = ""
    @Published var dailyAmountStatusString: String = ""
    @Published var isTapViewExpanded: Bool = false
    @Published var isAutoCounting: Bool = false

    private var timerInterval: Int?
    var timer: Timer?

    @Injected(Container.analyticsService) private var analyticsService
    @Injected(Container.subscriptionSyncService) private var subscriptionService
    @Injected(Container.appStatsService) private var appStatsService
    @Injected(Container.zikrService) private var zikrService
    let zikr: Zikr
    private let out: ZikrTapOut

    init(zikr: Zikr, out: @escaping ZikrTapOut) {
        self.zikr = zikr
        self.out = out
        totalCount = zikr.totalDoneCount
        count = zikr.currentDoneCount
        self.makeStatusString()
        NotificationCenter.default.addObserver(self, selector: #selector(observeForTimerPause), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(observeForTimerContinue), name: UIApplication.willEnterForegroundNotification, object: nil)
        
    }

    func zikrDidTap() {
        if appStatsService.isSoundEnabled && !isAutoCounting {
            AudioServicesPlaySystemSound(UInt32(appStatsService.soundId))
        }
        hapticLight()
        count += 1
        internalCount += 1
        totalCount += 1
        zikrService.updateZikrTotalCount(
            type: zikr.type,
            id: zikr.id,
            isSubscribed: subscriptionService.isSubscribed || appStatsService.isFreeProgressTrackingAvailable(),
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
            isSubscribed: subscriptionService.isSubscribed || appStatsService.isFreeProgressTrackingAvailable(),
            currentlyDoneCount: count,
            internalDoneCount: internalCount,
            totallyDoneCount: totalCount
        )
    }

    func setTimer(withInterval interval: Int) {
        appStatsService.didAutoCountToolTipPage()
        if subscriptionService.isSubscribed || appStatsService.canAutoCount {
            appStatsService.diddAutoCount()
            timerInterval = interval
            invalidate()
            withAnimation {
                isAutoCounting = true
            }
            timer = Timer.scheduledTimer(
                timeInterval: Double(interval),
                target: self,
                selector: #selector(self.advanceTimer(timer:)),
                userInfo: nil,
                repeats: true
            )
            AudioServicesPlaySystemSound(UInt32(appStatsService.soundId))
        } else {
            hapticStrong()
            out(.openPaywall)
        }
    }

    @objc private func advanceTimer(timer: Timer) {
        AudioServicesPlaySystemSound(UInt32(appStatsService.soundId))
        zikrDidTap()
    }

    @objc private func observeForTimerPause() {
        invalidate()
    }

    @objc private func observeForTimerContinue() {
        guard let timerInterval else { return }
        setTimer(withInterval: timerInterval)
    }

    func invalidate() {
        withAnimation {
            isAutoCounting = false
        }
        timer?.invalidate()
        timer = nil
    }

    func openPaywallIfNeeded() {
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
        analyticsService.trackOpenZikr(zikr: zikr)
    }

    func willDisappear() {
        hapticLight()
        analyticsService.trackCloseZikr(zikr: zikr, count: internalCount)
        close()
    }

    func deleteZikr() {
        hapticLight()
        out(.delete(delete))
    }

    func close() {
        invalidate()
        out(.close)
    }

    func removeFromTracker() {
        dailyAmount = "0"
        setAmount()
    }

    func setAmount() {
        guard let amount = Int(dailyAmount) else {
            return
        }
        let realm = try! Realm()
        if zikr.type == .zikr {
            guard let zikr = realm.objects(Zikr.self).where({ $0.id == zikr.id }).first else {
                return
            }
            try! realm.write {
                zikr.dailyTargetAmountAmount = amount
            }
            analyticsService.setZikrTrackerAmount(zikrId: zikr.id, zikrType: zikr.type, amount: amount)
        } else if zikr.type == .dua {
            guard let dua = realm.objects(Dua.self).where({ $0.id == zikr.id }).first else { return }
            try! realm.write {
                dua.dailyTargetAmountAmount = amount
            }
            analyticsService.setZikrTrackerAmount(zikrId: zikr.id, zikrType: zikr.type, amount: amount)
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
                    close()
                }
            } else if zikr.type == .dua {
                guard let dua = realm.objects(Dua.self).where({ $0.id == zikr.id }).first else { return }
                try realm.write {
                    realm.delete(dua)
                    close()
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
            dailyAmountStatusString = remainingAmount <= 0 ? "dailyAmountDone".localized(LocalizationService.shared.language) : "remaining".localized(LocalizationService.shared.language, args: String(remainingAmount))
        }
    }
}
