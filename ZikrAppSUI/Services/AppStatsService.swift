//
//  AppStatsService.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 20.08.2023.
//

import Factory
import RealmSwift

final class AppStatsService {
    var offering: QonversionOffering = .main
    @UserDefaultsValue(key: .didSetAppLang, defaultValue: false)
    var didSetAppLang: Bool

    @UserDefaultsValue(key: .qonversionId, defaultValue: "")
    var qonversionId: String

    // MARK: - Settings -

    @UserDefaultsValue(key: .isSoundEnabled, defaultValue: false)
    var isSoundEnabled: Bool

    @UserDefaultsValue(key: .soundId, defaultValue: 1105)
    var soundId: Int
    
    // MARK: - App First Open -

    @UserDefaultsValue(key: .appOpenCount, defaultValue: 0)
    public private(set) var openCount: Int
    var isFirstOpen: Bool {
        openCount <= 1
    }

    func didBecomeActive() {
        if openCount < Int.max {
            openCount += 1
        }
    }
    
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

    @UserDefaultsValue(key: .didAutoCountToolTip, defaultValue: false)
    var didAutoCountToolTip: Bool

    func didAutoCountToolTipPage() {
        guard !didAutoCountToolTip else { return }
        didAutoCountToolTip = true
    }

    @UserDefaultsValue(key: .numberOfAutoCount, defaultValue: 0)
    private var numberOfAutoCount: Int

    private let numberOfFreeAutoCounts: Int = 3

    var canAutoCount: Bool {
        numberOfAutoCount < numberOfFreeAutoCounts
    }

    func diddAutoCount() {
        guard numberOfAutoCount < numberOfFreeAutoCounts else { return }
        numberOfAutoCount += 1
    }

    @UserDefaultsValue(key: .didSeeStatisticsToolTip, defaultValue: false)
    var didSeeStatisticsToolTip: Bool

    func didSeeStatisticsToolTipPage() {
        guard !didSeeStatisticsToolTip else { return }
        didSeeStatisticsToolTip = true
    }

    @UserDefaultsValue(key: .didSeeManualProgressToolTip, defaultValue: false)
    var didSeeManualProgressToolTip: Bool

    func didSeeManualProgressToolTipPage() {
        guard !didSeeManualProgressToolTip else { return }
        didSeeManualProgressToolTip = true
    }

    func resetAllValues() {
        numberOfExpansion = 0
        didAddZikr = false
        didSeeWhatsNew = false
        didSeeOnboarding = false
        didSeeDailyAmountToolTip = false
        didSeeStatisticsToolTip = false
        didSeeManualProgressToolTip = false
        didAutoCountToolTip = false
        numberOfAutoCount = 0
    }

    // MARK: - JSON tranfferring -

    @UserDefaultsValue(key: .didFixTextsInVersion1_8, defaultValue: false)
    var didFixTextsInVersion1_8: Bool

    func didFixTextsInVersion1_8Action() {
        didFixTextsInVersion1_8 = true
    }
    
    func isFreeProgressTrackingAvailable() -> Bool {
        let realm = try! Realm()
        let progressesCount = realm.objects(DailyZikrProgress.self).where { $0.targetAmount == $0.amountDone }.count
        return progressesCount < 3
    }
}

extension Container {
    static let appStatsService = Factory<AppStatsService>(scope: .singleton) {
        .init()
    }
}
