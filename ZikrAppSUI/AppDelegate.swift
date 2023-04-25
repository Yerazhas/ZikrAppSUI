//
//  AppDelegate.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 15.01.2023.
//

import UIKit
import Amplitude
import Factory

@main
final class AppDelegate: NSObject, UIApplicationDelegate {
    @Injected(Container.analyticsService) private var analyticsService

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        transferDataToRealmIfNeeded()
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
        guard !UserDefaults.standard.bool(forKey: .didTransferZikrs) else { return }
        let service = ZikrService()
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
