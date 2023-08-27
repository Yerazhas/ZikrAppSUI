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
                if self.subscriptionsService.isSubscribed {
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

        if !appStatsService.didSeeWhatsNew {
            router.openWhatsNew {
                self.router.dismissPresentedVC {
                    self.openPaywallIfNeeded()
                }
            }
            appStatsService.didSeeWhatsNewPage()
        } else {
            if !appStatsService.didSeeOnboarding {
                router.openOnboarding {
                    self.router.dismissPresentedVC {
                        self.openPaywallIfNeeded()
                    }
                }
                appStatsService.didSeeOnboardingPage()
            }
        }

        if !appStatsService.didSetAppLang {
            router.openLanguageSetupAlert()
        }
    }

    private func openPaywallIfNeeded() {
        guard !subscriptionsService.isSubscribed else { return }
        self.router.openPaywall { cmd in
            switch cmd {
            case .close:
                self.router.dismissPresentedVC(nil)
            }
        }
    }
}

extension RootCoordinator: Hapticable {}
