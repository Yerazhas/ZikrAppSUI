//
//  SceneDelegate.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 17.01.2023.
//

import UIKit
import Factory

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    @Injected(Container.appStatsService) private var appStatsService
    @Injected(Container.analyticsService) private var analyticsService
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let rootVC = UINavigationController()
        UITabBar.appearance().scrollEdgeAppearance = UITabBarAppearance.init(idiom: .unspecified)
        rootVC.navigationBar.tintColor = .systemGreen
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        let coordinator = RootCoordinator(nc: rootVC)
        coordinator.run()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        analyticsService.trackAppOpen(isFirstOpen: appStatsService.isFirstOpen)
        appStatsService.didBecomeActive()
    }
}
