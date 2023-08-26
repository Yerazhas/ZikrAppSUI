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
