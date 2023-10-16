//
//  TrackerViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 25.07.2023.
//

import Foundation
import Combine
import RealmSwift
import Factory

typealias TrackerViewOut = (TrackerViewOutCmd) -> Void
enum TrackerViewOutCmd {
    case openZikr(Zikr)
    case openWird(Wird)
    case openPaywall
}

@MainActor
final class TrackerViewModel: ObservableObject, Hapticable {
    @Published var zikrs: Results<Zikr>?
    @Published var duas: Results<Dua>?
    @Published var wirds: Results<Wird>?
    @Published var qazaPrayers: [QazaViewModel] = []
    @Published var fullListQazaPrayers: [QazaViewModel] = []
    @Published var shortListQazaPrayers: [QazaViewModel] = []
    @Published var currentDate: Date = .init()
    @Published var weekSlider: [[DayProgress]] = []
    @Published var currentWeekIndex: Int = 1
    @Published var createWeek: Bool = false
    @Published var currentDayIdentificator: String
    @Published var zikrProgress: String = ""
    @Published var dailyAmount: String = ""
    @Published var selectedQazaPrayer: QazaPrayer?
    @Published var isFullQazaPrayersListShown: Bool = false

    @Injected(Container.zikrService) private var zikrService
    @Injected(Container.appStatsService) private var appStatsService
    @Injected(Container.analyticsService) private var analyticsService
    @Injected(Container.purchasesService) private var purchasesService
    @Injected(Container.subscriptionSyncService) private var subscriptionsService
    @Injected(Container.paywallProductsConverter) private var paywallProductsConverter
    var selectedZikr: Zikr?
    var selectedDua: Dua?
    var selectedWird: Wird?
    var hasZikrs: Bool {
        let areZikrsEmpty = zikrs?.isEmpty ?? true
        let areDuasEmpty = duas?.isEmpty ?? true
        let areWirdsEmpty = wirds?.isEmpty ?? true
        return !areZikrsEmpty || !areDuasEmpty || !areWirdsEmpty
    }
    var addZikrsCmd: TrackerAddZikrsOutCmd?
    private var cancellable: AnyCancellable?

    @Injected(Container.subscriptionSyncService) private var subscriptionService
    let out: TrackerViewOut

    init(out: @escaping TrackerViewOut) {
        self.out = out
        currentDayIdentificator = UUID().uuidString
        zikrs = getZikrs(for: .init())
        duas = getDuas(for: .init())
        wirds = getWirds(for: .init())
        fullListQazaPrayers = getQazaPrayers(for: .init())
        if let firstActiveQazaPrayer = fullListQazaPrayers.first(where: { !$0.isFinished }) {
            self.shortListQazaPrayers = [firstActiveQazaPrayer]
        }
        qazaPrayers = isFullQazaPrayersListShown ? fullListQazaPrayers : shortListQazaPrayers
    }

    func updateZikrs(for date: Date) {
        zikrs = getZikrs(for: date)
        duas = getDuas(for: date)
        wirds = getWirds(for: date)
        fullListQazaPrayers = getQazaPrayers(for: date)
        if let firstActiveQazaPrayer = fullListQazaPrayers.first(where: { !$0.isFinished }) {
            self.shortListQazaPrayers = [firstActiveQazaPrayer]
        }
        qazaPrayers = isFullQazaPrayersListShown ? fullListQazaPrayers : shortListQazaPrayers
    }

    private func getZikrs(for date: Date) -> Results<Zikr> {
        let realm = try! Realm()
        
        // Query all Zikrs
        let zikrs = realm.objects(Zikr.self)
        
        // Filter and create a list of Zikrs that meet the criteria
        var filteredZikrs: [Zikr] = []
        for zikr in zikrs {
            if date.isPastDay {
                if zikr.dailyProgress.contains(where: { (progress) -> Bool in
                    progress.date.isSame(to: date) && progress.isActive
                }) {
                    filteredZikrs.append(zikr)
                }
                // to stop newly added zikrs from appearing in previous days, when they weren't active
//                else if zikr.dailyTargetAmountAmount > 0 {
//                    filteredZikrs.append(zikr)
//                }
            } else {
                if zikr.dailyProgress.contains(where: { (progress) -> Bool in
                    progress.date.isSame(to: date) && progress.isActive
                }) {
                    filteredZikrs.append(zikr)
                } else if zikr.dailyTargetAmountAmount > 0 {
                    filteredZikrs.append(zikr)
                }
            }
        }
        
        // Convert the filtered Zikrs to a Results object
        return realm.objects(Zikr.self).filter("id IN %@", filteredZikrs.map({ $0.id }))
    }

    private func getQazaPrayers(for date: Date) -> [QazaViewModel] {
        let realm = try! Realm()
        let qazaPrayers = realm.objects(QazaPrayer.self)
        var filteredQazaPrayers: [QazaPrayer] = []
        for qazaPrayer in qazaPrayers {
            if qazaPrayer.targetAmount > 0 {
                filteredQazaPrayers.append(qazaPrayer)
            }
        }
        return realm.objects(QazaPrayer.self).filter("title IN %@", filteredQazaPrayers.map({ $0.id })).map { QazaViewModel(qazaPrayer: $0, date: date) }
    }

    private func getDuas(for date: Date) -> Results<Dua> {
        let realm = try! Realm()
        
        // Query all Zikrs
        let duas = realm.objects(Dua.self)
        
        // Filter and create a list of Zikrs that meet the criteria
        var filteredDuas: [Dua] = []
        for dua in duas {
            if date.isPastDay {
                if dua.dailyProgress.contains(where: { (progress) -> Bool in
                    progress.date.isSame(to: date) && progress.isActive
                }) {
                    filteredDuas.append(dua)
                }
//                else if dua.dailyTargetAmountAmount > 0 {
//                    filteredDuas.append(dua)
//                }
            } else {
                if dua.dailyProgress.contains(where: { (progress) -> Bool in
                    progress.date.isSame(to: date) && progress.isActive
                }) {
                    filteredDuas.append(dua)
                } else if dua.dailyTargetAmountAmount > 0 {
                    filteredDuas.append(dua)
                }
            }
        }
        
        // Convert the filtered Zikrs to a Results object
        return realm.objects(Dua.self).filter("id IN %@", filteredDuas.map({ $0.id }))
    }

    func openPaywall() {
        hapticLight()
        out(.openPaywall)
    }

    func setAmount() {
        guard let addZikrsCmd, let amount = Int(dailyAmount) else {
            return
        }
        let realm = try! Realm()
        switch addZikrsCmd {
        case .zikr(let zikr):
            guard let amount = Int(dailyAmount) else {
                return
            }
            guard let zikr = realm.objects(Zikr.self).where({ $0.id == zikr.id }).first else {
                return
            }
            try! realm.write {
                zikr.dailyTargetAmountAmount = amount
            }
            analyticsService.setZikrTrackerAmount(zikrId: zikr.id, zikrType: zikr.type, amount: amount)
        case .dua(let dua):
            guard let dua = realm.objects(Dua.self).where({ $0.id == dua.id }).first else { return }
            try! realm.write {
                dua.dailyTargetAmountAmount = amount
            }
            analyticsService.setZikrTrackerAmount(zikrId: dua.id, zikrType: dua.type, amount: amount)
        case .wird(let wird):
            guard let wird = realm.objects(Wird.self).where({ $0.id == wird.id }).first else {
                return
            }
            try! realm.write {
                wird.dailyTargetAmountAmount = amount
            }
            analyticsService.setZikrTrackerAmount(zikrId: wird.id, zikrType: wird.type, amount: amount)
        }
        self.addZikrsCmd = nil
        dailyAmount = ""
        onAppear()
    }

    func selectQazaPrayer(_ qazaPrayer: QazaPrayer) {
        hapticLight()
        selectedQazaPrayer = qazaPrayer
    }

    func changeFullListShownState() {
        hapticLight()
        isFullQazaPrayersListShown.toggle()
        qazaPrayers = isFullQazaPrayersListShown ? fullListQazaPrayers : shortListQazaPrayers
    }

    func getWirds(for date: Date) -> Results<Wird> {
        let realm = try! Realm()
        
        // Query all Zikrs
        let wirds = realm.objects(Wird.self)
        
        // Filter and create a list of Zikrs that meet the criteria
        var filteredWirds: [Wird] = []
        for wird in wirds {
            if date.isPastDay {
                if wird.dailyProgress.contains(where: { (progress) -> Bool in
                    progress.date.isSame(to: date) && progress.isActive
                }) {
                    filteredWirds.append(wird)
                }
//                else if wird.dailyTargetAmountAmount > 0 {
//                    filteredWirds.append(wird)
//                }
            } else {
                if wird.dailyProgress.contains(where: { (progress) -> Bool in
                    progress.date.isSame(to: date) && progress.isActive
                }) {
                    filteredWirds.append(wird)
                } else if wird.dailyTargetAmountAmount > 0 {
                    filteredWirds.append(wird)
                }
            }
        }
        
        // Convert the filtered Zikrs to a Results object
        return realm.objects(Wird.self).filter("id IN %@", filteredWirds.map({ $0.id }))
    }

    func updateQazaPrayer(with modifiedQazaPrayer: QazaPrayer) {
        guard let index = qazaPrayers.firstIndex(where: { $0.qazaPrayer.id == modifiedQazaPrayer.id }) else { return }
        qazaPrayers[index] = .init(qazaPrayer: modifiedQazaPrayer, date: .init())
    }

    func paginateWeek() {
        /// SafeCheck
        if weekSlider.indices.contains(currentWeekIndex) {
            if let firstDate = weekSlider[currentWeekIndex].first?.day.date, currentWeekIndex == 0 {
                /// Inserting New Week at 0th Index and Removing Last Array Item
                weekSlider.insert(firstDate.createPreviousWeek().map { $0.makeProgress() }, at: 0)
                weekSlider.removeLast()
                currentWeekIndex = 1
            }
            
            if let lastDate = weekSlider[currentWeekIndex].last?.day.date, currentWeekIndex == (weekSlider.count - 1) {
                /// Appending New Week at Last Index and Removing First Array Item
                weekSlider.append(lastDate.createNextWeek().map { $0.makeProgress() })
                weekSlider.removeFirst()
                currentWeekIndex = weekSlider.count - 2
            }
        }
    }

    @objc
    func onAppear() {
        currentDayIdentificator = UUID().uuidString
        updateZikrs(for: currentDate)
        weekSlider.removeAll()
        if weekSlider.isEmpty {
            let currentWeek = Date().fetchWeek()
            
            if let firstDate = currentWeek.first?.date {
                let weekDays = firstDate.createPreviousWeek()
                weekSlider.append(weekDays.map { $0.makeProgress() })
            }

            weekSlider.append(currentWeek.map { $0.makeProgress() })

            if let lastDate = currentWeek.last?.date {
                let weekDays = lastDate.createNextWeek()
                weekSlider.append(weekDays.map { $0.makeProgress() })
            }
        }
        fullListQazaPrayers = getQazaPrayers(for: .init())
        if let firstActiveQazaPrayer = fullListQazaPrayers.first(where: { !$0.isFinished }) {
            self.shortListQazaPrayers = [firstActiveQazaPrayer]
        }
        qazaPrayers = isFullQazaPrayersListShown ? fullListQazaPrayers : shortListQazaPrayers
//        else {
//            let currentWeek = Date().fetchWeek()
//            weekSlider.insert(currentWeek.map { $0.makeProgress() }, at: 1)
//        }
    }

    func openZikr(_ zikr: Zikr) {
        hapticLight()
        analyticsService.trackOpenTrackerZikr(zikrId: zikr.id, zikrType: zikr.type)
        guard currentDate.isToday else { return }
        openPaywallIfFreeProgressTrackingEnded(else: { self.out(.openZikr(zikr)) })
    }

    func openWird(_ wird: Wird) {
        hapticLight()
        analyticsService.trackOpenTrackerZikr(zikrId: wird.id, zikrType: .wird)
        guard currentDate.isToday else { return }
        openPaywallIfFreeProgressTrackingEnded(else: { self.out(.openWird(wird)) })
    }

    func zikrDidLongTap() {
        openPaywallIfFreeProgressTrackingEnded {
            self.setProgressForZikr()
        }
    }

    func addZikrs() {
        hapticLight()
        analyticsService.trackAddZikrsToTracker()
    }

    func openSupportPaywall() {
        analyticsService.trackOpenSupportPaywall()
    }

    func openStatistics() {
        analyticsService.trackOpenStatistics()
    }

    private func setProgressForZikr() {
        guard let zikr = selectedZikr, let amount = Int(zikrProgress) else { return }
        zikrService.updateZikrTotalCount(
            type: .zikr,
            id: zikr.id,
            isSubscribed: subscriptionService.isSubscribed || appStatsService.isFreeProgressTrackingAvailable(),
            currentlyDoneCount: amount,
            internalDoneCount: amount,
            totallyDoneCount: zikr.totalDoneCount
        )
        analyticsService.trackTrackererSetManualProgress(zikrId: zikr.id, zikrType: .zikr, progress: amount)
        selectedZikr = nil
        zikrProgress = ""
    }

    func duaDidLongTap() {
        openPaywallIfFreeProgressTrackingEnded {
            self.setProgressForDua()
        }
    }

    func contactSupport() {
        analyticsService.trackContactSupport()
    }

    private func setProgressForDua() {
        guard let dua = selectedDua, let amount = Int(zikrProgress) else { return }
        zikrService.updateZikrTotalCount(
            type: .dua,
            id: dua.id,
            isSubscribed: subscriptionService.isSubscribed || appStatsService.isFreeProgressTrackingAvailable(),
            currentlyDoneCount: amount,
            internalDoneCount: amount,
            totallyDoneCount: dua.totalDoneCount
        )
        analyticsService.trackTrackererSetManualProgress(zikrId: dua.id, zikrType: .dua, progress: amount)
        selectedDua = nil
        zikrProgress = ""
    }

    func wirdDidLongTap() {
        openPaywallIfFreeProgressTrackingEnded {
            self.setProgressForWird()
        }
    }

    private func setProgressForWird() {
        guard let wird = selectedWird, let amount = Int(zikrProgress) else { return }
        zikrService.updateZikrTotalCount(
            type: .wird,
            id: wird.id,
            isSubscribed: subscriptionService.isSubscribed || appStatsService.isFreeProgressTrackingAvailable(),
            currentlyDoneCount: amount,
            internalDoneCount: amount,
            totallyDoneCount: wird.totalDoneCount
        )
        analyticsService.trackTrackererSetManualProgress(zikrId: wird.id, zikrType: .wird, progress: amount)
        selectedWird = nil
        zikrProgress = ""
    }

    private func openPaywallIfFreeProgressTrackingEnded(else completion: @escaping () -> Void) {
        let realm = try! Realm()
        print(subscriptionService.isSubscribed)
        print(appStatsService.isFreeProgressTrackingAvailable())
        if !(subscriptionService.isSubscribed || appStatsService.isFreeProgressTrackingAvailable()) {
            out(.openPaywall)
            analyticsService.trackOpenTrackerPaywall()
        } else {
            completion()
        }
    }
}

struct DayProgress: Identifiable {
    let day: Date.WeekDay
    let progress: CGFloat

    var id: UUID {
        day.id
    }
}
