//
//  TrackerViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 25.07.2023.
//

import Foundation
import RealmSwift
import Factory

typealias TrackerViewOut = (TrackerViewOutCmd) -> Void
enum TrackerViewOutCmd {
    case openZikr(Zikr)
    case openWird(Wird)
    case openPaywall
}

final class TrackerViewModel: ObservableObject, Hapticable {
    @Published var zikrs: Results<Zikr>?
    @Published var duas: Results<Dua>?
    @Published var wirds: Results<Wird>?
    @Published var currentDate: Date = .init()
    @Published var weekSlider: [[DayProgress]] = []
    @Published var currentWeekIndex: Int = 1
    @Published var createWeek: Bool = false
    @Published var currentDayIdentificator: String
    @Injected(Container.subscriptionSyncService) private var subscriptionService
    let out: TrackerViewOut

    init(out: @escaping TrackerViewOut) {
        self.out = out
        currentDayIdentificator = UUID().uuidString
        zikrs = getZikrs(for: .init())
        duas = getDuas(for: .init())
        wirds = getWirds(for: .init())
        NotificationCenter.default.addObserver(self, selector: #selector(onAppear), name: NSNotification.Name.NSSystemClockDidChange, object: nil)
    }

    func updateZikrs(for date: Date) {
        zikrs = getZikrs(for: date)
        duas = getDuas(for: date)
        wirds = getWirds(for: date)
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
//        else {
//            let currentWeek = Date().fetchWeek()
//            weekSlider.insert(currentWeek.map { $0.makeProgress() }, at: 1)
//        }
    }

    func openZikr(_ zikr: Zikr) {
        hapticLight()
        guard currentDate.isToday else { return }
        openPaywallIfFreeProgressTrackingEnded(else: { self.out(.openZikr(zikr)) })
    }

    func openWird(_ wird: Wird) {
        hapticLight()
        guard currentDate.isToday else { return }
        openPaywallIfFreeProgressTrackingEnded(else: { self.out(.openWird(wird)) })
    }

    private func openPaywallIfFreeProgressTrackingEnded(else completion: @escaping () -> Void) {
        let realm = try! Realm()
        let progressesCount = realm.objects(DailyZikrProgress.self).where { $0.amountDone == $0.targetAmount }.count
        if !subscriptionService.isSubscribed && progressesCount >= 12 {
            out(.openPaywall)
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
