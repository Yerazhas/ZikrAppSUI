//
//  RootCoordinator.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 17.01.2023.
//

import UIKit
import Factory

final class RootCoordinator {
    private let router: RootRouter
    private let reviewService: ReviewService = .shared
    private let language = LocalizationService.shared.language
    @Injected(Container.subscriptionSyncService) private var subscriptionsService
    @Injected(Container.appStatsService) private var appStatsService

    init(nc: UINavigationController?) {
        router = RootRouterImpl(nc)
    }

    func run() {
        router.openMain { cmd in
            switch cmd {
            case .openZikr(let zikr):
                self.router.openZikr(zikr) { cmd in
                    switch cmd {
                    case .close:
                        self.router.dismissPresentedVC(nil)
                        self.reviewService.requestReviewIfPossible()
                    case .delete(let action):
                        self.router.showAlert(message: "deleteZikr".localized(self.language), action: action)
                    case .openPaywall:
                        self.router.openPaywall { cmd in
                            switch cmd {
                            case .close:
                                self.router.dismissPresentedVC(nil)
                            }
                        }
                    }
                }
            case .openDua(let dua):
                self.router.openDua(dua) { cmd in
                    switch cmd {
                    case .close:
                        self.router.dismissPresentedVC(nil)
                        self.reviewService.requestReviewIfPossible()
                    case .delete(let action):
                        self.router.showAlert(message: "deleteDua".localized(self.language), action: action)
                    case .openPaywall:
                        self.router.openPaywall { cmd in
                            switch cmd {
                            case .close:
                                self.router.dismissPresentedVC(nil)
                            }
                        }
                    }
                }
            case .openWird(let wird):
                self.router.openWird(wird) { cmd in
                    switch cmd {
                    case .close:
                        self.router.dismissPresentedVC(nil)
                        self.reviewService.requestReviewIfPossible()
                    case .delete(let action):
                        self.router.showAlert(message: "deleteWird".localized(self.language), action: action)
                    case .openPaywall:
                        self.router.openPaywall { cmd in
                            switch cmd {
                            case .close:
                                self.router.dismissPresentedVC(nil)
                            }
                        }
                    }
                }
            case .openSettings:
                self.router.openSettings { cmd in
                    switch cmd {
                    case .openPaywall:
                        self.router.dismissPresentedVC(nil)
                        self.router.openPaywall { cmd in
                            switch cmd {
                            case .close:
                                self.router.dismissPresentedVC(nil)
                            }
                        }
                    }
                }
            case .openAddNew:
                if self.subscriptionsService.isSubscrtibed {
                    self.router.openAddNew { cmd in
                        switch cmd {
                        case .success:
    //                        self.router.popToRoot()
                            self.router.dismissPresentedVC(nil)
                        case .error(let message):
                            self.router.showInfoAlert(message: message)
                        }
                    }
                } else {
                    if self.appStatsService.didAddZikr {
                        self.hapticStrong()
                        self.router.openPaywall { cmd in
                            switch cmd {
                            case .close:
                                self.router.dismissPresentedVC(nil)
                            }
                        }
                    } else {
                        self.router.openAddNew { cmd in
                            switch cmd {
                            case .success:
        //                        self.router.popToRoot()
                                self.router.dismissPresentedVC(nil)
                            case .error(let message):
                                self.router.showInfoAlert(message: message)
                            }
                        }
                    }
                }
            case .openPaywall:
                self.router.openPaywall { cmd in
                    switch cmd {
                    case .close:
                        self.router.dismissPresentedVC(nil)
                    }
                }
            }
        }

        let didSeeWhatsNew = UserDefaults.standard.bool(forKey: .didSeeWhatsNew)
        if !didSeeWhatsNew {
            router.openWhatsNew {
                self.router.dismissPresentedVC(nil)
                self.openPaywallIfNeeded()
            }
            UserDefaults.standard.set(true, forKey: .didSeeWhatsNew)
        } else {
            let didSeeOnboarding = UserDefaults.standard.bool(forKey: .didSeeOnboarding)
            if didSeeOnboarding {
                router.openOnboarding {
                    self.router.dismissPresentedVC {
                        self.openPaywallIfNeeded()
                    }
                }
                UserDefaults.standard.set(true, forKey: .didSeeOnboarding)
            }
        }
        
        let didSetAppLang = UserDefaults.standard.bool(forKey: .didSetAppLang)
        if !didSetAppLang {
            router.openLanguageSetupAlert()
        }
    }

    private func openPaywallIfNeeded() {
        guard !subscriptionsService.isSubscrtibed else { return }
        self.router.openPaywall { cmd in
            switch cmd {
            case .close:
                self.router.dismissPresentedVC(nil)
            }
        }
    }
}

extension RootCoordinator: Hapticable {}
