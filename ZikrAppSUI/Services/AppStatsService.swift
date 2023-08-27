//
//  AppStatsService.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 20.08.2023.
//

import Factory

final class AppStatsService {
    @UserDefaultsValue(key: .didSetAppLang, defaultValue: false)
    var didSetAppLang: Bool
    
    // MARK: - Expansion -
    
    @UserDefaultsValue(key: .numberOfExpansion, defaultValue: 0)
    private var numberOfExpansion: Int

    private let numberOfFreeExpansions: Int = 10

    var canExpand: Bool {
        numberOfExpansion < numberOfFreeExpansions
    }

    func didExpand() {
        guard numberOfExpansion < numberOfFreeExpansions else { return }
        numberOfExpansion += 1
    }

    // MARK: - Add New Zikr -

    @UserDefaultsValue(key: .didAddNewZikr, defaultValue: false)
    var didAddZikr: Bool

    func setDidAddZikr() {
        guard !didAddZikr else { return }
        didAddZikr = true
    }

    // MARK: - What's New Page -

    @UserDefaultsValue(key: .didSeeWhatsNew, defaultValue: false)
    var didSeeWhatsNew: Bool

    func didSeeWhatsNewPage() {
        didSeeWhatsNew = true
    }

    // MARK: - Onboarding -

    @UserDefaultsValue(key: .didSeeOnboarding, defaultValue: false)
    var didSeeOnboarding: Bool

    func didSeeOnboardingPage() {
        didSeeOnboarding = true
    }

    // MARK: - ToopTip Onboarding -

    @UserDefaultsValue(key: .didSeeDailyAmountToolTip, defaultValue: false)
    var didSeeDailyAmountToolTip: Bool

    func didSeeDailyAmountToolTipPage() {
        guard !didSeeDailyAmountToolTip else { return }
        didSeeDailyAmountToolTip = true
    }

    @UserDefaultsValue(key: .didSeeStatisticsToolTip, defaultValue: false)
    var didSeeStatisticsToolTip: Bool

    func didSeeStatisticsToolTipPage() {
        guard !didSeeStatisticsToolTip else { return }
        didSeeStatisticsToolTip = true
    }

    func resetAllValues() {
        numberOfExpansion = 0
        didAddZikr = false
        didSeeWhatsNew = false
        didSeeOnboarding = false
        didSeeDailyAmountToolTip = false
        didSeeStatisticsToolTip = false
    }
}

extension Container {
    static let appStatsService = Factory<AppStatsService> {
        .init()
    }
}
