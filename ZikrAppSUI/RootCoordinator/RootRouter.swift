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
    func openMain(out: @escaping MainOut)

    func openZikr(_ zikr: Zikr,  _ out: @escaping () -> Void)
    func openDua(_ dua: Dua,  _ out: @escaping () -> Void)
    func openWird(_ wird: Wird,  _ out: @escaping WirdTapOut)
    func openSettings()
    func openLanguageSetupAlert()
    func openAddNew(out: @escaping AddNewOut)

    func dismissPresentedVC()
    func showInfoAlert(message: String)
    func popToRoot()
    func showAlert(message: String, action: @escaping () -> Void)
}

final class RootRouterImpl: RootRouter {
    private weak var nc: UINavigationController?
    @Injected(Container.localizationService) private var localizationService
    @Injected(Container.analyticsService) private var analyticsService

    init(_ nc: UINavigationController?) {
        self.nc = nc
    }

    func openMain(out: @escaping MainOut) {
        let view = MainView(out: out)
        nc?.set(suiView: view, animated: false)
    }

    func openZikr(_ zikr: Zikr, _ out: @escaping () -> Void) {
        let view = ZikrTapView(zikr: zikr, out: out)
        let vc = UIHostingController(rootView: view)
        vc.modalPresentationStyle = .fullScreen
        nc?.present(vc, animated: true)
    }

    func openDua(_ dua: Dua,  _ out: @escaping () -> Void) {
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

    func openSettings() {
        let view = SettingsView()
        let vc = UIHostingController(rootView: view)
        vc.modalPresentationStyle = .pageSheet
        nc?.present(vc, animated: true)
    }

    func openLanguageSetupAlert() {
        let language = localizationService.language
        let alertVC = UIAlertController(title: "selectLanguage".localized(language), message: nil, preferredStyle: .alert)
        let enAction = UIAlertAction(title: "English", style: .default) { _ in
            self.localizationService.language = .en
            UserDefaults.standard.setValue(true, forKey: .didSetAppLang)
            self.analyticsService.setUserProperties(["locale": self.localizationService.language.rawValue])
        }
        let kzAction = UIAlertAction(title: "Қазақша", style: .default) { _ in
            self.localizationService.language = .kz
            UserDefaults.standard.setValue(true, forKey: .didSetAppLang)
            self.analyticsService.setUserProperties(["locale": self.localizationService.language.rawValue])
        }
        let ruAction = UIAlertAction(title: "Русский".localized(language), style: .default) { _ in
            self.localizationService.language = .ru
            UserDefaults.standard.setValue(true, forKey: .didSetAppLang)
            self.analyticsService.setUserProperties(["locale": self.localizationService.language.rawValue])
        }
        alertVC.addAction(enAction)
        alertVC.addAction(kzAction)
        alertVC.addAction(ruAction)
        nc?.present(alertVC, animated: true)
    }

    func openAddNew(out: @escaping AddNewOut) {
        let view = AddNewView(out: out)
        let vc = UIHostingController(rootView: view)
//        nc?.present(vc, animated: true)
        nc?.pushViewController(vc, animated: true)
    }

    func dismissPresentedVC() {
        nc?.presentedViewController?.dismiss(animated: true)
    }

    func showInfoAlert(message: String) {
        let language = localizationService.language
        let alertVC = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok".localized(language), style: .default)
        alertVC.addAction(okAction)
        nc?.present(alertVC, animated: true)
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
