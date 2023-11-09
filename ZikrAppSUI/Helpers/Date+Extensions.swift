//
//  Date+Extensions.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 24.07.2023.
//

import Foundation
import RealmSwift

extension Date {
    var string: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: LocalizationService.shared.language.rawValue)
        return dateFormatter.string(from: self)
    }
}

/// Date Extensions Needed for Building UI
extension Date {
    /// Custom Date Format
    func format(_ format: String, locale: Locale) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        
        return formatter.string(from: self)
    }
    
    /// Checking Whether the Date is Today
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    /// Checking if the date is Same Hour
    var isSameHour: Bool {
        return Calendar.current.compare(self, to: .init(), toGranularity: .hour) == .orderedSame
    }

    func isSame(to date: Date) -> Bool {
        Calendar.current.compare(self, to: date, toGranularity: .day) == .orderedSame
    }
    
    /// Checking if the date is Past Hours
    var isPast: Bool {
        return Calendar.current.compare(self, to: .init(), toGranularity: .hour) == .orderedAscending
    }

    var isPastDay: Bool {
        return Calendar.current.compare(self, to: .init(), toGranularity: .day) == .orderedAscending
    }

    func isOlderThan(date: Date) -> Bool {
        Calendar.current.compare(self, to: .init(), toGranularity: .day) == .orderedAscending
    }
    
    /// Fetching Week Based on given Date
    func fetchWeek(_ date: Date = .init()) -> [WeekDay] {
        let calendar = Calendar.current
        let startOfDate = calendar.startOfDay(for: date)
        
        var week: [WeekDay] = []
        let weekForDate = calendar.dateInterval(of: .weekOfMonth, for: startOfDate)
        guard let starOfWeek = weekForDate?.start else {
            return []
        }
        
        /// Iterating to get the Full Week
        (0..<7).forEach { index in
            if let weekDay = calendar.date(byAdding: .day, value: index, to: starOfWeek) {
                week.append(.init(date: weekDay))
            }
        }
        
        return week
    }
    
    /// Creating Next Week, based on the Last Current Week's Date
    func createNextWeek() -> [WeekDay] {
        let calendar = Calendar.current
        let startOfLastDate = calendar.startOfDay(for: self)
        guard let nextDate = calendar.date(byAdding: .day, value: 1, to: startOfLastDate) else {
            return []
        }
        
        return fetchWeek(nextDate)
    }
    
    /// Creating Previous Week, based on the First Current Week's Date
    func createPreviousWeek() -> [WeekDay] {
        let calendar = Calendar.current
        let startOfFirstDate = calendar.startOfDay(for: self)
        guard let previousDate = calendar.date(byAdding: .day, value: -1, to: startOfFirstDate) else {
            return []
        }
        
        return fetchWeek(previousDate)
    }
    
    struct WeekDay: Identifiable {
        var id: UUID = .init()
        var date: Date
    }
}

func datesForCurrentYear() -> [Date] {
    let calendar = Calendar.current
    let currentDate = Date()

    let year = calendar.component(.year, from: currentDate)

    var dates: [Date] = []

    for month in 1...12 {
        var components = DateComponents()
        components.year = year
        components.month = month

        if let firstDateOfMonth = calendar.date(from: components),
           let lastDateOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDateOfMonth) {
            let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: firstDateOfMonth)?.count ?? 0
            let dateRange = (0..<numberOfDaysInMonth).compactMap {
                calendar.date(byAdding: .day, value: $0, to: firstDateOfMonth)
            }
            dates.append(contentsOf: dateRange)
        }
    }

    return dates
}

extension Date.WeekDay {
    func makeProgress() -> DayProgress {
        let realm = try! Realm()
        let zikrs = realm.objects(Zikr.self)
        let duas = realm.objects(Dua.self)
        let wirds = realm.objects(Wird.self)

        var dailyProgresses: [DailyZikrProgress] = []

        for zikr in zikrs {
            if let progress = zikr.dailyProgress.first(where: { progress in
                progress.date.isSame(to: self.date) && progress.isActive
            }) {
                dailyProgresses.append(progress)
            } else if date.isToday && zikr.dailyTargetAmountAmount > 0 {
                dailyProgresses.append(.init(date: date, targetAmount: zikr.dailyTargetAmountAmount, amountDone: 0, isActive: true))
            }
        }

        for dua in duas {
            if let progress = dua.dailyProgress.first(where: { progress in
                progress.date.isSame(to: self.date) && progress.isActive
            }) {
                dailyProgresses.append(progress)
            }
        }

        for wird in wirds {
            if let progress = wird.dailyProgress.first(where: { progress in
                progress.date.isSame(to: self.date) && progress.isActive
            }) {
                dailyProgresses.append(progress)
            }
        }

        let totalDoneCount = dailyProgresses.map { $0.amountDone }.reduce(0, +)
        let totalTargetAmount = dailyProgresses.map { $0.targetAmount }.reduce(0, +)
        let progress = totalTargetAmount == 0 ? 0 : CGFloat(totalDoneCount) / CGFloat(totalTargetAmount)
        return DayProgress(day: self, progress: progress)
    }
}
