//
//  RootCoordinator.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 17.01.2023.
//

import UIKit

final class RootCoordinator {
    private let router: RootRouter
    private let reviewService: ReviewService = .shared
    private let language = LocalizationService.shared.language

    init(nc: UINavigationController?) {
        router = RootRouterImpl(nc)
    }

    func run() {
        router.openMain { cmd in
            switch cmd {
            case .openZikr(let zikr):
                self.router.openZikr(zikr) {
                    self.router.dismissPresentedVC()
                    self.reviewService.requestReviewIfPossible()
                }
            case .openDua(let dua):
                self.router.openDua(dua) {
                    self.router.dismissPresentedVC()
                    self.reviewService.requestReviewIfPossible()
                }
            case .openWird(let wird):
                self.router.openWird(wird) { cmd in
                    switch cmd {
                    case .close:
                        self.router.dismissPresentedVC()
                        self.reviewService.requestReviewIfPossible()
                    case .delete(let action):
                        self.router.showAlert(message: "deleteWird".localized(self.language), action: action)
                    }
                }
            case .openSettings:
                self.router.openSettings()
            case .openAddNew:
                self.router.openAddNew { cmd in
                    switch cmd {
                    case .success:
                        self.router.popToRoot()
                    case .error(let message):
                        self.router.showInfoAlert(message: message)
                    }
                }
            }
        }
        let didSetAppLang = UserDefaults.standard.bool(forKey: .didSetAppLang)
        if !didSetAppLang {
            router.openLanguageSetupAlert()
        }
    }
}
