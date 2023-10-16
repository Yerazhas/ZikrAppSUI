//
//  AnalyticsService.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 19.02.2023.
//

import Foundation
import Amplitude
import Factory

final class AnalyticsService {
    enum Event: String {
        case appFirstOpen = "app_first_open"
        case appOpen = "app_open"

        case openCounter = "open_counter"
        case closeCounter = "close_counter"
        case openZikrs = "open_zikrs"
        case openZikr = "open_zikr"
        case openDua = "open_dua"
        case openWird = "open_wird"
        case closeZikr = "close_zikr"
        case closeDua = "close_dua"
        case closeWird = "close_wird"
        case openSettings = "open_settings"
        case shareApp = "share_app"
        case rateApp = "rate_app"
        case openInstagram = "open_instagram"
        case setNotificationDate = "set_notification_date"

        case openPaywall = "open_paywall"
        case selectPaywallProduct = "select_paywall_product"
        case subscribe = "subscribe"
        case subscriptionSuccess = "subscription_success"
        case subscriptionError = "subscription_error"

        case addNew = "add_new"
        case addNewSuccess = "add_new_success"

        case addZikrsToTracker = "add_zikrs_to_tracker"
        case seeStatistics = "see_statistics"
        case openTrackerPaywall = "open_tracker_paywall"
        case openTrackerZikr = "open_tracker_zikr"
        case trackerSetManualProgress = "tracker_set_manual_progress"
        case setZikrTrackerAmount = "set_zikr_tracker_amount"
        case contactSupport = "contact_support"

        case showOnboarding = "show_onboarding"
        case showKaspiOnboarding = "show_kaspi_onboarding"
        case showWhatsNew = "show_whats_new"

        case openSupportPaywall = "open_support_paywall"
        case openEnterPromocodes = "open_enter_promocodes"
        case promocodeActivation = "promocode_activation"

        case donationSuccess = "donation_success"
        case donationError = "donation_error"
        case donation = "donation"

        case payKaspi = "pay_kaspi"
        case sendCheck = "send_check"
    }

    func trackAppOpen(isFirstOpen: Bool) {
        track(event: isFirstOpen ? .appFirstOpen : .appOpen)
    }

    func trackOpenZikr(zikr: Zikr) {
        if zikr.type == .zikr {
            track(
                event: .openZikr,
                properties: [
                    "zikr": zikr.title,
                    "total_done_count": String(zikr.totalDoneCount)
                ]
            )
        } else if zikr.type == .dua {
            track(
                event: .openDua,
                properties: [
                    "dua": zikr.title,
                    "total_done_count": String(zikr.totalDoneCount)
                ]
            )
        }
    }

    func trackCloseZikr(zikr: Zikr, count: Int) {
        if zikr.type == .zikr {
            track(
                event: .closeZikr,
                properties: [
                    "zikr": zikr.title,
                    "done_count": String(count),
                    "total_done_count": String(zikr.totalDoneCount)
                ]
            )
        } else if zikr.type == .dua {
            track(
                event: .closeDua,
                properties: [
                    "dua": zikr.title,
                    "done_count": String(count),
                    "total_done_count": String(zikr.totalDoneCount)
                ]
            )
        }
    }

    func trackCloseWird(wird: Wird, count: Int) {
        track(
            event: .closeWird,
            properties: [
                "wird": wird.title,
                "total_done_count": String(count)
            ]
        )
    }

    func trackOpenWird(wird: Wird) {
        track(
            event: .openWird,
            properties: [
                "wird": wird.title,
                "total_done_count": String(wird.totalDoneCount)
            ]
        )
    }

    func trackOpenZikrs(zikrType: ZikrType) {
        track(event: .openZikrs, properties: ["zikr_type": zikrType.rawValue])
    }

    func trackOpenCounter(count: Int) {
        track(event: .openCounter, properties: ["counter": String(count)])
    }

    func trackCloseCounter(count: Int) {
        track(event: .closeCounter, properties: ["counter": String(count)])
    }

    func trackOpenSettings() {
        track(event: .openSettings)
    }

    func trackShareApp() {
        track(event: .shareApp)
    }

    func trackRateApp() {
        track(event: .rateApp)
    }

    func trackOpenInstagram() {
        track(event: .openInstagram)
    }

    func trackNotificationDateSet(firstDate: String?, secondDate: String?) {
        var props: [String: String] = [
            "first_date": "null",
            "second_date": "null"
        ]
        if let firstDate {
            props["first_date"] = firstDate
        }
        if let secondDate {
            props["second_date"] = secondDate
        }
        track(
            event: .setNotificationDate,
            properties: props
        )
    }

    func trackOpenPaywall() {
        track(event: .openPaywall)
    }

    func trackSelectPaywallProduct(id: String) {
        let props = ["product_id": id]
        track(event: .selectPaywallProduct, properties: props)
    }

    func trackSubscription(productId: String, price: String) {
        let props = ["product_id": productId, "price": price]
        track(event: .subscribe, properties: props)
    }

    func trackSubscriptionSuccess(productId: String, price: String) {
        let props = ["product_id": productId, "price": price]
        track(event: .subscriptionSuccess, properties: props)
    }

    func trackSubscriptionError(productId: String, error: String) {
        let props = ["product_id": productId, "error_message": error]
        track(event: .subscriptionError, properties: props)
    }

    func trackOpenAddNew() {
        track(event: .addNew)
    }

    func trackAddNewSuccess(zikrType: ZikrType) {
        let props = ["zikr_type": zikrType.rawValue]
        track(event: .addNewSuccess, properties: props)
    }

    func trackAddZikrsToTracker() {
        track(event: .addZikrsToTracker)
    }

    func trackOpenStatistics() {
        track(event: .seeStatistics)
    }

    func trackOpenTrackerPaywall() {
        track(event: .openTrackerPaywall)
    }

    func trackOpenTrackerZikr(zikrId: String, zikrType: ZikrType) {
        let props = ["zikr_id": zikrId, "zikr_type": zikrType.rawValue]
        track(event: .openTrackerZikr, properties: props)
    }

    func trackTrackererSetManualProgress(zikrId: String, zikrType: ZikrType, progress: Int) {
        let props = ["zikr_id": zikrId, "zikr_type": zikrType.rawValue, "progress": String(progress)]
        track(event: .trackerSetManualProgress, properties: props)
    }

    func trackOpenSupportPaywall() {
        track(event: .openSupportPaywall)
    }

    func trackContactSupport() {
        track(event: .contactSupport)
    }

    func trackOpenEnterPromocodes() {
        track(event: .openEnterPromocodes)
    }

    func trackPromocodeActivation(renewState: Int) {
        track(event: .promocodeActivation, properties: ["is_subscribed": String([-1, 1].contains(renewState)), "renew_state": String(renewState)])
    }

    func trackDonation(productId: String) {
        track(event: .donation, properties: ["product_id": productId])
    }

    func trackDonationSuccess(productId: String) {
        track(event: .donationSuccess, properties: ["product_id": productId])
    }

    func trackPayKaspi() {
        track(event: .payKaspi)
    }

    func trackSendCheck() {
        track(event: .sendCheck)
    }

    func trackShowOnboarding() {
        track(event: .showOnboarding)
    }

    func trackShowKaspiOnboarding() {
        track(event: .showKaspiOnboarding)
    }

    func trackShowWhatsNew() {
        track(event: .showWhatsNew)
    }

    func trackDonationError(productId: String, error: String) {
        track(event: .donationError, properties: ["product_id": productId, "error_message": error])
    }

    func setUserProperties(_ properties: [String: String]) {
        Amplitude.instance().setUserProperties(properties)
    }

    func setZikrTrackerAmount(zikrId: String, zikrType: ZikrType, amount: Int) {
        let props = ["zikr_id": zikrId, "zikr_type": zikrType.rawValue, "amount": String(amount)]
        track(event: .setZikrTrackerAmount, properties: props)
    }

    private func track(event: Event, properties: [String: String]? = nil) {
        Amplitude.instance().logEvent(event.rawValue, withEventProperties: properties)
    }
}

extension Container {
    static let analyticsService = Factory<AnalyticsService> {
        AnalyticsService()
    }
}
