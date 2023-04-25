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

    func setUserProperties(_ properties: [String: String]) {
        Amplitude.instance().setUserProperties(properties)
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
