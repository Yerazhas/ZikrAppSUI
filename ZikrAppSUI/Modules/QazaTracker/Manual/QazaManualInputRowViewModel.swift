//
//  ManualQazaInputRowViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 08.10.2023.
//

import Foundation

final class QazaManualInputRowViewModel: PrayerAmountRowViewModel {
    private let prayerType: PrayerType

    init(count: Int, title: String?, prayerType: PrayerType, isEditable: Bool = true) {
        self.prayerType = prayerType
        super.init(count: count, title: title, isEditable: isEditable)
    }
}

enum PrayerType: String, Identifiable {
    case fajr

    case dhuhr
    case safarDhuhr

    case asr
    case safarAsr

    case maghrib

    case isha
    case safarIsha

    case witr

    case fast
    
    var id: String {
        rawValue
    }

    var imageName: String {
        switch self {
        case .fajr:
            return "sun.haze"
        case .dhuhr:
            return "sun.max"
        case .safarDhuhr:
            return "sun.max"
        case .asr:
            return "cloud.sun"
        case .safarAsr:
            return "cloud.sun"
        case .maghrib:
            return "moon"
        case .isha:
            return "moon.stars"
        case .safarIsha:
            return "moon.stars"
        case .witr:
            return "moon.zzz"
        case .fast:
            return "fork.knife"
        }
    }
}
