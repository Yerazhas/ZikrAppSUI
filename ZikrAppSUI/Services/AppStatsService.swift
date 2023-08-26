//
//  AppStatsService.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 20.08.2023.
//

import Factory

final class AppStatsService {
    @UserDefaultsValue(key: .didAddNewZikr, defaultValue: false)
    var didAddZikr: Bool

    @UserDefaultsValue(key: .numberOfExpansion, defaultValue: 0)
    private var numberOfExpansion: Int
    private let numberOfFreeExpansions: Int = 10

    var canExpand: Bool {
        numberOfExpansion < numberOfFreeExpansions
    }

    func setDidAddZikr() {
        guard !didAddZikr else { return }
        didAddZikr = true
    }

    func didExpand() {
        guard numberOfExpansion < numberOfFreeExpansions else { return }
        numberOfExpansion += 1
    }
}

extension Container {
    static let appStatsService = Factory<AppStatsService> {
        .init()
    }
}
