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

@main
final class AppDelegate: NSObject, UIApplicationDelegate {
    @Injected(Container.analyticsService) private var analyticsService

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        transferDataToRealmIfNeeded()
        UIPageControl.appearance().isUserInteractionEnabled = false
        UIPageControl.appearance().currentPageIndicatorTintColor = .black
//        let config = Realm.Configuration(schemaVersion: 3)
//        Realm.Configuration.defaultConfiguration = config
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

    private func transferDataToRealmIfNeeded() {
        let service = ZikrService()
        guard !UserDefaults.standard.bool(forKey: .didTransferZikrs) else {
//            if !UserDefaults.standard.bool(forKey: .didTransferZikrs1) {
//                service.transferZikrsFromJson1()
//                service.transferDuasFromJson1()
////                service.transferWirdsFromJson1()
//            }
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
