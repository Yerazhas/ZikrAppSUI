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
                self.router.openWird(wird) {
                    self.router.dismissPresentedVC()
                    self.reviewService.requestReviewIfPossible()
                }
            case .openSettings:
                self.router.openSettings()
            case .openAddNew:
                self.router.openAddNew()
            }
        }
        let didSetAppLang = UserDefaults.standard.bool(forKey: .didSetAppLang)
        if !didSetAppLang {
            router.openLanguageSetupAlert()
        }
    }
}
