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

@main
final class AppDelegate: NSObject, UIApplicationDelegate {
    @Injected(Container.analyticsService) private var analyticsService
    @Injected(Container.purchasesService) private var purchasesService
    @Injected(Container.subscriptionSyncService) private var subscriptionService
    @Injected(Container.appStatsService) private var appStatsService

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        let config = Realm.Configuration(schemaVersion: 2)
        Realm.Configuration.defaultConfiguration = config
        setupQonversion()
        checkSubscriptions()
        transferDataToRealmIfNeeded()
        UIPageControl.appearance().isUserInteractionEnabled = false
        UIPageControl.appearance().currentPageIndicatorTintColor = .black
        configureAmplitude()
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
//        Qonversion.shared().attachUser(toExperiment: "ea330055-0941-411e-a596-9cea547f1e4c", groupId: "77405f32") { _, _ in
//            Qonversion.shared().remoteConfig { remoteConfig, error in
//                if let remoteConfig {
//                    let offerindId = remoteConfig.payload?["offering_id"] as? String ?? "paywall_1"
//                    self.appStatsService.offering = .init(rawValue: offerindId) ?? .main
//                }
//            }
//        }

        Qonversion.shared().remoteConfig { remoteConfig, error in
            if let remoteConfig {
                let offerindId = remoteConfig.payload?["offering_id"] as? String ?? "paywall_1"
                self.appStatsService.offering = .init(rawValue: offerindId) ?? .main
            }
        }
    }

    private func checkSubscriptions() {
        Task {
            do {
                let isSubscribed = try await purchasesService.checkSubscription()
                subscriptionService.updateSubscriptionStatus(to: isSubscribed)
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
            if !appStatsService.didFixTextsInVersion1_8 {
                service.fixTextsInVersion1_8()
                appStatsService.didFixTextsInVersion1_8Action()
            }
            return
        }
        service.transferZikrsFromJson()
        service.transferDuasFromJson()
        service.transferWirdsFromJson()
        UserDefaults.standard.set(true, forKey: .didTransferZikrs)
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
