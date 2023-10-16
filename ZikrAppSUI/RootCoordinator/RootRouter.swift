//
//  RootRouter.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 17.01.2023.
//

import UIKit
import SwiftUI
import Factory

protocol RootRouter: AnyObject {
    func openSplash(completion: @escaping () -> Void)
    func openWelcome(completion: @escaping () -> Void)
    func openMain(out: @escaping MainOut)

    func openZikr(_ zikr: Zikr,  _ out: @escaping ZikrTapOut)
    func openDua(_ dua: Dua,  _ out: @escaping ZikrTapOut)
    func openWird(_ wird: Wird,  _ out: @escaping WirdTapOut)
    func openSettings(out: @escaping SettingsOut)
    func openLanguageSetupAlert(completion: @escaping () -> Void)
    func openAddNew(out: @escaping AddNewOut)
    func openPaywall(out: @escaping PaywallViewOut)
    func openWhatsNew(out: @escaping () -> Void)
    func openOnboarding(out: @escaping () -> Void)
    func openKaspiOnboarding(out: @escaping () -> Void)
    func openReviewRequest(completion: @escaping () -> Void)
    func openCounter(out: @escaping CounterOut)

    func dismissPresentedVC(onlyPresentedVC: Bool, _ completion: (() -> Void)?)
    func showInfoAlert(message: String)
    func popToRoot()
    func showAlert(message: String, action: @escaping () -> Void)
}

extension RootRouter {
    func dismissPresentedVC(onlyPresentedVC: Bool = true, _ completion: (() -> Void)?) {
        dismissPresentedVC(onlyPresentedVC: onlyPresentedVC, completion)
    }
}

final class RootRouterImpl: RootRouter {
    private weak var nc: UINavigationController?
    @Injected(Container.localizationService) private var localizationService
    @Injected(Container.analyticsService) private var analyticsService

    init(_ nc: UINavigationController?) {
        self.nc = nc
    }

    func openSplash(completion: @escaping () -> Void) {
        let view = SplashView(completion: completion)
        nc?.set(suiView: view)
    }

    func openWelcome(completion: @escaping () -> Void) {
        let view = WelcomeView(completion: completion)
        let vc = UIHostingController(rootView: view)
        vc.modalPresentationStyle = .fullScreen
        nc?.present(vc, animated: true)
    }

    func openMain(out: @escaping MainOut) {
        let view = MainView(out: out)
        nc?.set(suiView: view, animated: false)
    }

    func openZikr(_ zikr: Zikr, _ out: @escaping ZikrTapOut) {
        let view = ZikrTapView(zikr: zikr, out: out)
        let vc = UIHostingController(rootView: view)
        vc.modalPresentationStyle = .fullScreen
        nc?.present(vc, animated: true)
    }

    func openDua(_ dua: Dua,  _ out: @escaping ZikrTapOut) {
        let view = ZikrTapView(zikr: dua, out: out)
        let vc = UIHostingController(rootView: view)
        vc.modalPresentationStyle = .fullScreen
        nc?.present(vc, animated: true)
    }

    func openWird(_ wird: Wird,  _ out: @escaping WirdTapOut) {
        let view = WirdTapView(wird: wird, out: out)
        let vc = UIHostingController(rootView: view)
        vc.modalPresentationStyle = .fullScreen
        nc?.present(vc, animated: true)
    }

    func openSettings(out: @escaping SettingsOut) {
        let view = SettingsView(out: out)
        let vc = UIHostingController(rootView: view)
        vc.modalPresentationStyle = .pageSheet
        nc?.present(vc, animated: true)
    }

    func openLanguageSetupAlert(completion: @escaping () -> Void) {
        let language = localizationService.language
        let alertVC = UIAlertController(title: "selectLanguage".localized(language), message: nil, preferredStyle: .alert)
        let enAction = UIAlertAction(title: "English", style: .default) { _ in
            self.localizationService.language = .en
            UserDefaults.standard.setValue(true, forKey: .didSetAppLang)
            self.analyticsService.setUserProperties(["locale": self.localizationService.language.rawValue])
            completion()
        }
        let kzAction = UIAlertAction(title: "Қазақша", style: .default) { _ in
            self.localizationService.language = .kz
            UserDefaults.standard.setValue(true, forKey: .didSetAppLang)
            self.analyticsService.setUserProperties(["locale": self.localizationService.language.rawValue])
            completion()
        }
        let ruAction = UIAlertAction(title: "Русский".localized(language), style: .default) { _ in
            self.localizationService.language = .ru
            UserDefaults.standard.setValue(true, forKey: .didSetAppLang)
            self.analyticsService.setUserProperties(["locale": self.localizationService.language.rawValue])
            completion()
        }
        alertVC.addAction(enAction)
        alertVC.addAction(kzAction)
        alertVC.addAction(ruAction)
        nc?.present(alertVC, animated: true)
    }

    func openAddNew(out: @escaping AddNewOut) {
        let view = AddNewView(out: out)
        let vc = UIHostingController(rootView: view)
        vc.modalPresentationStyle = .pageSheet
        nc?.present(vc, animated: true)
    }

    func openPaywall(out: @escaping PaywallViewOut) {
        let vc = UIHostingController(rootView: PaywallView(out: out))
        vc.modalPresentationStyle = .fullScreen
        if nc?.presentedViewController != nil {
            nc?.presentedViewController?.present(vc, animated: true)
        } else {
            nc?.present(vc, animated: true)
        }
    }

    func openWhatsNew(out: @escaping () -> Void) {
        let vc = UIHostingController(rootView: WhatsNewView(completion: out))
        vc.modalPresentationStyle = .pageSheet
        nc?.present(vc, animated: true)
        analyticsService.trackShowWhatsNew()
    }

    func openOnboarding(out: @escaping () -> Void) {
        let vc = UIHostingController(rootView:
                                        OnboardingView(
                                            pagesData: [
                                                .init(imageName: "SC 54", titleKey: "onboarding_title_1", subtitleKey: "onboarding_subtitle_1"),
                                                .init(imageName: "SC 55", titleKey: "onboarding_title_2", subtitleKey: "onboarding_subtitle_2"),
                                                .init(imageName: "SC 56", titleKey: "onboarding_title_3", subtitleKey: "onboarding_subtitle_3")
                                            ],
                                            completion: out
                                        )
        )
        vc.modalPresentationStyle = .fullScreen
        nc?.present(vc, animated: true)
        analyticsService.trackShowOnboarding()
    }

    func openKaspiOnboarding(out: @escaping () -> Void) {
        let view = OnboardingView(
            pagesData: [
                .init(imageName: "SC 59", titleKey: "kaspiIsAvailable", subtitleKey: nil)
            ],
            completion: out
        )
        let vc = UIHostingController(rootView: view)
        vc.modalPresentationStyle = .fullScreen
        nc?.present(vc, animated: true)
        analyticsService.trackShowKaspiOnboarding()
    }

    func openReviewRequest(completion: @escaping () -> Void) {
        let view = ReviewRequestView(completion: completion)
        let vc = UIHostingController(rootView: view)
        vc.modalPresentationStyle = .fullScreen
        nc?.present(vc, animated: true)
    }

    func openCounter(out: @escaping CounterOut) {
        let view = CounterView(out: out)
        let vc = UIHostingController(rootView: view)
        vc.modalPresentationStyle = .fullScreen
        nc?.present(vc, animated: true)
    }

    func dismissPresentedVC(onlyPresentedVC: Bool, _ completion: (() -> Void)?) {
        if onlyPresentedVC {
            nc?.presentedViewController?.dismiss(animated: true, completion: completion)
        } else {
            nc?.dismiss(animated: true, completion: completion)
        }
    }

    func showInfoAlert(message: String) {
        let language = localizationService.language
        let alertVC = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok".localized(language), style: .default)
        alertVC.addAction(okAction)
        nc?.presentedViewController?.present(alertVC, animated: true)
    }

    func popToRoot() {
        nc?.popViewController(animated: true)
    }

    func showAlert(message: String, action: @escaping () -> Void) {
        let language = localizationService.language
        let alertVC = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok".localized(language), style: .default) { _ in
            action()
        }
        let cancelAction = UIAlertAction(title: "cancel".localized(language), style: .cancel)
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        nc?.presentedViewController?.present(alertVC, animated: true)
    }
 }
