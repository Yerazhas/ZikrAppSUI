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
    @Published var products: [PaywallProduct] = []
    @Published var state: State = .loading
    @Published private(set) var selectedProduct: PaywallProduct?
    @Published var isButtonLoading: Bool = false

    @Injected(Container.purchasesService) private var purchasesService
    @Injected(Container.subscriptionSyncService) private var subscriptionsService
    @Injected(Container.analyticsService) private var analyticsService
    @Injected(Container.appStatsService) private var appStatsService
    @Injected(Container.paywallProductsConverter) private var paywallProductsConverter

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
        analyticsService.trackOpenPaywall()
        getProducts()
    }

    func getProducts() {
        Task {
            do {
                self.state = .loading
                let products = try await purchasesService.getProducts(offeringId: appStatsService.offering)
                self.products = paywallProductsConverter.convertByExpensive(products: products)
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

    func selectProduct(_ product: PaywallProduct) {
        hapticLight()
        selectedProduct = product
        analyticsService.trackSelectPaywallProduct(id: product.product.storeID)
    }

    func purchase() {
        guard let selectedProduct else { return }
        analyticsService.trackSubscription(productId: selectedProduct.product.storeID)
        Task {
            do {
                setButtonLoading(to: true)
                let isSuccessful = try await purchasesService.purchase(product: selectedProduct.product)
                subscriptionsService.updateSubscriptionStatus(to: isSuccessful)
                setButtonLoading(to: false)
                if isSuccessful {
                    state = .purchaseSuccess
                    analyticsService.trackSubscriptionSuccess(productId: selectedProduct.product.storeID)
                }
            } catch let error as PurchasesError {
                setButtonLoading(to: false)
                state = .failed(error)
                analyticsService.trackSubscriptionError(productId: selectedProduct.product.storeID, error: error.localizedDescription)
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
