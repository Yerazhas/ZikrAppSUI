//
//  ProfileViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 24.10.2023.
//

import Combine
import Foundation
import SwiftUI
import Factory
import AudioToolbox
import UniformTypeIdentifiers

struct NotificationTime: Codable {
    let hour: Int
    let minute: Int
}

enum SoundState {
    case off
    case on(Int)
}

typealias ProfileOut = (ProfileOutCmd) -> Void
enum ProfileOutCmd {
    case openPaywall
    case openRussiaPaymentTutorial
}

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var isFirstDateSet: Bool = false
    @Published var firstDate: Date = .init()
    @Published var isSecondDateSet: Bool = false
    @Published var secondDate: Date = .init()
    @Published var isSoundEnabled: Bool = false
    @Published var soundId: Int = 0
    @Published var shouldShowBanner: Bool = false
    let out: ProfileOut

    @AppStorage(.firstNotificationDate) var firstNotificationDate: Data?
    @AppStorage(.secondNotificationDate) var secondNotificationDate: Data?
    @Injected(Container.appStatsService) private var appStatsService
    @Injected(Container.purchasesService) private var purchasesService
    @Injected(Container.subscriptionSyncService) private var subscriptionSyncService
    @Injected(Container.paywallProductsConverter) private var paywallProductsConverter
    @Injected(Container.analyticsService) private var analyticsService
    @Injected(Container.subscriptionSyncService) private var subscriptionService

    private var firstNotificationIds: [String] = []
    private var secondNotificationIds: [String] = []
    private var firstDateString: String?
    private var secondDateString: String?
    private var cancellable: AnyCancellable?

    init(out: @escaping ProfileOut) {
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

        isSoundEnabled = appStatsService.isSoundEnabled
        soundId = appStatsService.soundId
        shouldShowBanner = subscriptionService.isSubscribed
        cancellable = subscriptionService.isSubscribedPublisher.sink { [weak self] isSubscribed in
            self?.shouldShowBanner = !isSubscribed
        }
    }

    deinit {
        cancellable = nil
    }

    func reset() {
        firstNotificationDate = nil
        secondNotificationDate = nil
        isFirstDateSet = false
        isSecondDateSet = false
    }

    func scheduleFirstNotification() {
        guard isFirstDateSet else { return }
        hapticLight()
        let dateComponents = Calendar.current.dateComponents(in: TimeZone.current, from: firstDate)
        var newDateComponents = DateComponents()
        newDateComponents.hour = dateComponents.hour
        newDateComponents.minute = dateComponents.minute
        firstDateString = "\(dateComponents.hour ?? -1):\(dateComponents.minute ?? -1)"
//        analyticsService.trackNotificationDateSet(firstDate: firstDateString, secondDate: secondDateString)
        let time = NotificationTime(hour: newDateComponents.hour ?? 0, minute: newDateComponents.minute ?? 0)
        guard let data = try? JSONEncoder().encode(time) else { return }
        UserDefaults.standard.set(data, forKey: .firstNotificationDate)
        scheduleNotification(newDateComponents, isFirst: true)
    }

    func scheduleSecondNotification() {
        hapticLight()
        guard isSecondDateSet else { return }
        let dateComponents = Calendar.current.dateComponents(in: TimeZone.current, from: secondDate)
        var newDateComponents = DateComponents()
        newDateComponents.hour = dateComponents.hour
        newDateComponents.minute = dateComponents.minute
        secondDateString = "\(dateComponents.hour ?? -1):\(dateComponents.minute ?? -1)"
//        analyticsService.trackNotificationDateSet(firstDate: firstDateString, secondDate: secondDateString)
        let time = NotificationTime(hour: newDateComponents.hour ?? 0, minute: newDateComponents.minute ?? 0)
        guard let data = try? JSONEncoder().encode(time) else { return }
        UserDefaults.standard.set(data, forKey: .secondNotificationDate)
        scheduleNotification(newDateComponents, isFirst: false)
    }

    func openRussiaPaymentTutorial() {
        hapticLight()
        out(.openRussiaPaymentTutorial)
    }

    func setSound(to state: SoundState) {
        switch state {
        case .off:
            hapticLight()
            appStatsService.isSoundEnabled = false
            isSoundEnabled = false
        case .on(let soundId):
            if subscriptionSyncService.isSubscribed {
                hapticLight()
                appStatsService.isSoundEnabled = true
                isSoundEnabled = true

                appStatsService.soundId = soundId
                self.soundId = soundId
                AudioServicesPlaySystemSound(UInt32(appStatsService.soundId))
            } else {
                hapticStrong()
                openPaywall()
            }
        }
    }

    func openPaywall() {
        hapticLight()
        out(.openPaywall)
    }

    func activateIfPossible() {
        if appStatsService.isLifetimeActivationEnabled {
            appStatsService.isActivatedByCode = true
            hapticLight()
        }
    }

    func copyQonversionUserIdToClipboard() {
        hapticStrong()
        UIPasteboard.general.setValue(appStatsService.qonversionId,
                    forPasteboardType: UTType.plainText.identifier)
    }

    private func scheduleNotification(_ dateComponents: DateComponents, isFirst: Bool) {
        let id = "\(dateComponents.hour ?? 0)\(dateComponents.minute ?? 0)"
        let ids = isFirst ? firstNotificationIds : secondNotificationIds
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ids)
        let content = UNMutableNotificationContent()
        content.title = "notificationTitle".localized(LocalizationService.shared.language)
        content.subtitle = "notificationSubtitle".localized(LocalizationService.shared.language)
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

extension ProfileViewModel: Hapticable {}

extension Bundle {
    static func versionString() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
}

extension String {
    static let firstNotificationDate = "firstNotificationDate"
    static let secondNotificationDate = "secondNotificationDate"
}
