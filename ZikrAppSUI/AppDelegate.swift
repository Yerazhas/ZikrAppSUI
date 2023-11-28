//
//  AppDelegate.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 15.01.2023.
//

import UIKit
import Amplitude
import Factory
import RealmSwift
import Qonversion
import FirebaseCore

@main
final class AppDelegate: NSObject, UIApplicationDelegate {
    @Injected(Container.analyticsService) private var analyticsService
    @Injected(Container.purchasesService) private var purchasesService
    @Injected(Container.subscriptionSyncService) private var subscriptionService
    @Injected(Container.appStatsService) private var appStatsService
    @Injected(Container.themeService) private var themeService

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        let config = Realm.Configuration(schemaVersion: 3)
        Realm.Configuration.defaultConfiguration = config
        configureFirebase()
        setupQonversion()
        checkSubscriptions()
        transferDataToRealmIfNeeded()
        setDefaultTrackerZikrsIfNeeded()

        UIPageControl.appearance().currentPageIndicatorTintColor = .systemGreen

        configureAmplitude()
        themeService.setDefaultTheme()
//        let realm = try! Realm()
//        let prayers = realm.objects(QazaPrayer.self)
//        let safarPrayers = realm.objects(SafarQazaPrayer.self)
//        try! realm.write({
//            for prayer in prayers {
//                realm.delete(prayer)
//            }
//            for prayer in safarPrayers {
//                realm.delete(prayer)
//            }
//        })
//        UserDefaults.standard.set(false, forKey: "didSetUpQaza")
//        appStatsService.resetAllValues() // Remove before release
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "asd", sessionRole: connectingSceneSession.role)
    }

    private func setupQonversion() {
        let config = Qonversion.Configuration(projectKey: "BNHjF_H9A61rSvb3gTHFzzWINg1znf-n", launchMode: .subscriptionManagement)
        Qonversion.initWithConfig(config)
        Qonversion.shared().setEntitlementsUpdateListener(self)
        Qonversion.shared().userInfo { user, _ in
            if let userId = user?.qonversionId {
                self.appStatsService.qonversionId = userId
            }
        }

//        // TODO: remove before submission
//        Qonversion.shared().attachUser(toExperiment: "433c7db1-4483-4651-bc2b-4cdf01fb7ea9", groupId: "879adac4") { _, _ in
//            Qonversion.shared().remoteConfig { remoteConfig, error in
//                if let remoteConfig {
//                    let offerindId = remoteConfig.payload?["offering_id"] as? String ?? "paywall_1"
//                    self.appStatsService.offering = .init(rawValue: offerindId) ?? .main
//                }
//            }
//        }

//        Qonversion.shared().remoteConfig { remoteConfig, error in
//            if let remoteConfig {
//                let offerindId = remoteConfig.payload?["offering_id"] as? String ?? "paywall_1"
//                self.appStatsService.offering = .init(rawValue: offerindId) ?? .main

//                let halfDiscountOfferingId = remoteConfig.payload?["discount_offering_id"] as? String ?? "paywall_half_discount"
//                self.appStatsService.halfDiscountOffering = .init(rawValue: halfDiscountOfferingId) ?? .halfDiscount
//            }
//        }
    }

    private func configureFirebase() {
        FirebaseApp.configure()
    }

    private func checkSubscriptions() {
        Task {
            do {
                if appStatsService.isActivatedByCode {
                    subscriptionService.updateSubscriptionStatus(to: true)
                } else {
                    let isSubscribed = try await purchasesService.checkSubscription()
                    subscriptionService.updateSubscriptionStatus(to: isSubscribed)
                }
            } catch {
//                subscriptionService.updateSubscriptionStatus(to: false)
                print(error)
            }
        }
    }

    private func transferDataToRealmIfNeeded() {
        let service = ZikrService()
        guard !UserDefaults.standard.bool(forKey: .didTransferZikrs) else {
            if !UserDefaults.standard.bool(forKey: .didTransferZikrs1) {
                service.transferZikrsFromJson1()
                service.transferDuasFromJson1()
//                service.transferWirdsFromJson1()
            }
            UserDefaults.standard.set(true, forKey: .didTransferZikrs1)
            if !appStatsService.didFixTextsInVersion2_0_4 {
                service.fixTextsInVersion2_0_4()
                appStatsService.didFixTextsInVersion2_0_4Action()
            }
            if !appStatsService.didFixTextsInVersion1_9 {
                service.fixTextsInVersion1_9_0()
                appStatsService.didFixTextsInVersion1_9Action()
            }
//            if !UserDefaults.standard.bool(forKey: "didTransferDuasForPalestine") {
//                service.addPalestineDuas()
//                UserDefaults.standard.set(true, forKey: "didTransferDuasForPalestine")
//            }
//              TODO: Add below duas to duas.json and uncomment Palestine method in zikr service
//            {
//                "id": "antaMawlana",
//                "title": "antaMawlana",
//                "arabicTitle": "أَنْتَ مَوْلَانَا فَانْصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ"
//            },
//            {
//                "id": "shamYaman",
//                "title": "shamYaman",
//                "arabicTitle": "اللهُمَّ بَارِكْ لَنَا فِي شَامِنَا وَفِي يَمَنِنَا"
//            },
//            {
//                "id": "munzilalKitab",
//                "title": "munzilalKitab",
//                "arabicTitle": "اللَّهُمَّ مُنْزِلَ الْكِتَابِ، سَرِيعَ الْحِسَابِ، اهْزِمِ الْأَحْزَابِ، اللَّهُمَّ اهْزِمْهُمْ وَزَلْزِلْهُمْ"
//            },
//            {
//                "id": "rabbulMadhlumeen",
//                "title": "rabbulMadhlumeen",
//                "arabicTitle": "اللَّهُمَّ إِنَّكَ رَبُّ الْمَظْلُومِين. اللَّهُمَّ أَنصُرِ الْمَظْلُمِينَ عَلَى قَوْمِ الظَّالِمِين فِي كُلِّ مَكَانٍ. اللَّهُمَّ ارْحَمْ أُمَّةَ مُحَمَّدٍ. اللَّهُمَّ أَرْسِلِ الْفَرَجَ لأُمَّةِ مُحَمَّدٍ."
//            },
//            {
//                "id": "innaNaj'aluka",
//                "title": "innaNaj'aluka",
//                "arabicTitle": "اللهم إِنَّا نَجْعَلُكَ فِي نُحُورِهِم وَنَعُوذُ بِكَ مِنْ شُرُورِهِم"
//            },
            return
        }
        service.transferZikrsFromJson()
        service.transferDuasFromJson()
        service.transferWirdsFromJson()
        UserDefaults.standard.set(true, forKey: .didTransferZikrs)
    }

    private func setDefaultTrackerZikrsIfNeeded() {
        let zikrService = ZikrService()
        let realm = try! Realm()
        let hasNoTrackedZikrs = realm.objects(Zikr.self).where({ $0.dailyTargetAmountAmount > 0 }).isEmpty
        let hasNoTrackedDuas = realm.objects(Dua.self).where({ $0.dailyTargetAmountAmount > 0 }).isEmpty
        let hasNoTrackedWirds = realm.objects(Wird.self).where({ $0.dailyTargetAmountAmount > 0 }).isEmpty
        let hasNoTraction = hasNoTrackedDuas && hasNoTrackedZikrs && hasNoTrackedWirds

        guard !subscriptionService.isSubscribed && hasNoTraction else { return }
        zikrService.setDefaultTrackerZikrs()
    }

    private func configureAmplitude() {
        Amplitude.instance().trackingSessionEvents = true
        Amplitude.instance().initializeApiKey("c56952486da4ca3108ad45598872665d")
        Amplitude.instance().logEvent("app_start")
        analyticsService.setUserProperties(["locale": LocalizationService.shared.language.rawValue])
    }
}

extension AppDelegate: Qonversion.EntitlementsUpdateListener {
    func didReceiveUpdatedEntitlements(_ entitlements: [String : Qonversion.Entitlement]) {
        if let premium: Qonversion.Entitlement = entitlements["Premium"], premium.isActive {
            analyticsService.trackPromocodeActivation(renewState: premium.renewState.rawValue)
            switch premium.renewState {
            case .willRenew, .nonRenewable:
                // .willRenew is the state of an auto-renewable subscription
                // .nonRenewable is the state of consumable/non-consumable IAPs that could unlock lifetime access
                subscriptionService.updateSubscriptionStatus(to: true)
            case .billingIssue:
                // Grace period: entitlement is active, but there was some billing issue.
                // Prompt the user to update the payment method.

                subscriptionService.updateSubscriptionStatus(to: false)
            case .cancelled:
                // The user has turned off auto-renewal for the subscription, but the subscription has not expired yet.
                // Prompt the user to resubscribe with a special offer.
                subscriptionService.updateSubscriptionStatus(to: false)
            default:
                subscriptionService.updateSubscriptionStatus(to: false)
            }
        } else {
            subscriptionService.updateSubscriptionStatus(to: false)
        }
    }
}
