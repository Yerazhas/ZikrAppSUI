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
        router.openSplash {
            self.runMain()
        }
    }

    private func runMain() {
        router.openMain { cmd in
            switch cmd {
            case .openZikr(let zikr):
                self.router.openZikr(zikr) { cmd in
                    switch cmd {
                    case .close:
                        self.router.dismissPresentedVC(nil)
                        self.requestReviewIfPossible()
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
                        self.requestReviewIfPossible()
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
                UIPageControl.appearance().isUserInteractionEnabled = false
                self.router.openWird(wird) { cmd in
                    switch cmd {
                    case .close:
                        self.router.dismissPresentedVC(nil)
                        self.requestReviewIfPossible()
                        UIPageControl.appearance().isUserInteractionEnabled = true
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
            case .openCounter:
                self.router.openCounter { cmd in
                    switch cmd {
                    case .close:
                        self.router.dismissPresentedVC(nil)
                    }
                }
            case .openRussiaPaymentTutorial:
                self.openRussiaPaymentSafariVC()
            }
        }
        if !appStatsService.didSetAppLang {
            router.openLanguageSetupAlert {
                self.launchOnboardings()
            }
        } else {
            launchOnboardings()
        }
    }

    private func launchOnboardings() {
        if !appStatsService.didSeeWelcome {
            router.openWelcome {
                self.router.dismissPresentedVC {
                    self.router.openOnboarding {
                        self.router.dismissPresentedVC {
                            self.openPaywallIfNeeded()
                        }
                    }
                    self.appStatsService.didSeeOnboardingPage()
                }
            }
            appStatsService.didSeeWelcomePage()
        } else {
            presentRussiaPaymentAlert()
        }
    }

    private func presentRussiaPaymentAlert() {
        if Locale.current.regionCode == "RU" && !appStatsService.didSeeRussiaPaymentAlert {
            router.openRussiaPaymentAlert { [weak self] in
                self?.openRussiaPaymentSafariVC()
            }
            appStatsService.didSeeRussiaPaymentAlertPage()
        }
    }

    private func openRussiaPaymentSafariVC() {
        guard let url = URL(string: "https://appleinsider.ru/tips-tricks/kak-polozhit-dengi-na-apple-id-luchshie-sposoby.html") else { return }
        router.openSafariBrowserVC(url: url)
    }

    private func requestReviewIfPossible() {
        if !appStatsService.didSeeReviewRequest && !subscriptionsService.isSubscribed {
            router.openReviewRequest {
                self.router.dismissPresentedVC(nil)
            }
            appStatsService.didSeeReviewRequestPage()
        } else {
            reviewService.requestReviewIfPossible()
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
