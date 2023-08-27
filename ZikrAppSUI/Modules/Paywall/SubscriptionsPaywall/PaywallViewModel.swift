//
//  PaywallViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 13.08.2023.
//

import Combine
import Qonversion
import Factory

typealias PaywallViewOut = (PaywallViewOutCmd) -> Void
enum PaywallViewOutCmd {
    case close
}

@MainActor
final class PaywallViewModel: ObservableObject, LoadingButtonViewModel {
    enum State {
        case loading
        case loaded
        case failed(Error)
        case purchaseSuccess
    }
    @Published var products: [Qonversion.Product] = []
    @Published var state: State = .loading
    @Published private(set) var selectedProduct: Qonversion.Product?
    @Published var isButtonLoading: Bool = false

    @Injected(Container.purchasesService) private var purchasesService
    @Injected(Container.subscriptionSyncService) private var subscriptionsService

    let benefits: [String] = [
        "paywallBenefits1",
        "paywallBenefits2",
        "paywallBenefits3"
    ]
    let out: PaywallViewOut

    init(out: @escaping PaywallViewOut) {
        self.out = out
    }
    
    func onAppear() {
        getProducts()
    }

    func getProducts() {
        Task {
            do {
                self.state = .loading
                self.products = try await purchasesService.getProducts(offeringId: .main)
                self.selectedProduct = self.products.dropLast().last
                self.state = .loaded
            } catch {
                self.state = .failed(error)
            }
        }
    }

    func close() {
        hapticLight()
        out(.close)
    }

    func selectProduct(_ product: Qonversion.Product) {
        hapticLight()
        selectedProduct = product
    }

    func purchase() {
        guard let selectedProduct else { return }
        Task {
            do {
                setButtonLoading(to: true)
                let isSuccessful = try await purchasesService.purchase(product: selectedProduct)
                subscriptionsService.updateSubscriptionStatus(to: isSuccessful)
                setButtonLoading(to: false)
                if isSuccessful {
                    state = .purchaseSuccess
                }
            } catch let error as PurchasesError {
                setButtonLoading(to: false)
                state = .failed(error)
            }
        }
    }

    func restorePurchases() {
        Task {
            do {
                let isSubscribed = try await purchasesService.restorePurchases()
                subscriptionsService.updateSubscriptionStatus(to: isSubscribed)
            } catch {
                state = .failed(error)
            }
        }
    }
}

extension PaywallViewModel: Hapticable {}
