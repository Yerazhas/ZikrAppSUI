//
//  SettingsViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 21.01.2023.
//

import Foundation
import Combine
import UserNotifications
import UIKit
import SwiftUI
import Factory

struct NotificationTime: Codable {
    let hour: Int
    let minute: Int
}

final class SettingsViewModel: ObservableObject {
    @Published var isFirstDateSet: Bool = false
    @Published var firstDate: Date = .init()
    @Published var isSecondDateSet: Bool = false
    @Published var secondDate: Date = .init()
    @AppStorage(.firstNotificationDate) var firstNotificationDate: Data?
    @AppStorage(.secondNotificationDate) var secondNotificationDate: Data?
    @Injected(Container.analyticsService) private var analyticsService
    let out: SettingsOut
    private var cancellables = Set<AnyCancellable>()
    private var firstNotificationIds: [String] = []
    private var secondNotificationIds: [String] = []
    private var firstDateString: String?
    private var secondDateString: String?

    init(out: @escaping SettingsOut) {
        self.out = out
        if let firstNotificationDate, let time = try? JSONDecoder().decode(NotificationTime.self, from: firstNotificationDate) {
            var dateComponents = DateComponents()
            dateComponents.hour = time.hour
            dateComponents.minute = time.minute
            firstDateString = "\(time.hour):\(time.minute)"
            if let date = Calendar.current.date(from: dateComponents) {
                isFirstDateSet = true
                firstDate = date
            }
        }
        if let secondNotificationDate, let time = try? JSONDecoder().decode(NotificationTime.self, from: secondNotificationDate) {
            var dateComponents = DateComponents()
            dateComponents.hour = time.hour
            dateComponents.minute = time.minute
            secondDateString = "\(time.hour):\(time.minute)"
            if let date = Calendar.current.date(from: dateComponents) {
                isSecondDateSet = true
                secondDate = date
            }
        }
        analyticsService.trackNotificationDateSet(firstDate: firstDateString, secondDate: secondDateString)
    }

    func scheduleFirstNotification() {
        guard isFirstDateSet else { return }
        let dateComponents = Calendar.current.dateComponents(in: TimeZone.current, from: firstDate)
        var newDateComponents = DateComponents()
        newDateComponents.hour = dateComponents.hour
        newDateComponents.minute = dateComponents.minute
        firstDateString = "\(dateComponents.hour ?? -1):\(dateComponents.minute ?? -1)"
        analyticsService.trackNotificationDateSet(firstDate: firstDateString, secondDate: secondDateString)
        let time = NotificationTime(hour: newDateComponents.hour ?? 0, minute: newDateComponents.minute ?? 0)
        guard let data = try? JSONEncoder().encode(time) else { return }
        UserDefaults.standard.set(data, forKey: .firstNotificationDate)
        scheduleNotification(newDateComponents, isFirst: true)
    }

    func scheduleSecondNotification() {
        guard isSecondDateSet else { return }
        let dateComponents = Calendar.current.dateComponents(in: TimeZone.current, from: secondDate)
        var newDateComponents = DateComponents()
        newDateComponents.hour = dateComponents.hour
        newDateComponents.minute = dateComponents.minute
        secondDateString = "\(dateComponents.hour ?? -1):\(dateComponents.minute ?? -1)"
        analyticsService.trackNotificationDateSet(firstDate: firstDateString, secondDate: secondDateString)
        let time = NotificationTime(hour: newDateComponents.hour ?? 0, minute: newDateComponents.minute ?? 0)
        guard let data = try? JSONEncoder().encode(time) else { return }
        UserDefaults.standard.set(data, forKey: .secondNotificationDate)
        scheduleNotification(newDateComponents, isFirst: false)
    }

    func reset() {
        firstNotificationDate = nil
        secondNotificationDate = nil
        isFirstDateSet = false
        isSecondDateSet = false
    }

    func onAppear() {
        analyticsService.trackOpenSettings()
    }

    func openPaywall() {
        out(.openPaywall)
    }

    private func scheduleNotification(_ dateComponents: DateComponents, isFirst: Bool) {
        let id = "\(dateComponents.hour ?? 0)\(dateComponents.minute ?? 0)"
        let ids = isFirst ? firstNotificationIds : secondNotificationIds
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ids)
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notificationTitle", comment: "")
        content.subtitle = NSLocalizedString("notificationSubtitle", comment: "")
        content.sound = UNNotificationSound.default
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        if isFirst {
            firstNotificationIds.append(id)
        } else {
            secondNotificationIds.append(id)
        }
    }
}

extension String {
    static let firstNotificationDate = "firstNotificationDate"
    static let secondNotificationDate = "secondNotificationDate"
}
