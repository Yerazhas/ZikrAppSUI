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
    func openWird(_ wird: Wird,  _ out: @escaping () -> Void)
    func openSettings()
    func openLanguageSetupAlert()
    func openAddNew()

    func dismissPresentedVC()
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

    func openWird(_ wird: Wird,  _ out: @escaping () -> Void) {
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

    func openAddNew() {
        let view = AddNewView()
        let vc = UIHostingController(rootView: view)
        nc?.present(vc, animated: true)
    }

    func dismissPresentedVC() {
        nc?.presentedViewController?.dismiss(animated: true)
    }
 }
