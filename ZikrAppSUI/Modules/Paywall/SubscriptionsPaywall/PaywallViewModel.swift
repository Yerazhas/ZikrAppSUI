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

    @Published var error: PurchasesError?
    @Published var shouldShowLoader: Bool = false

    @Injected(Container.purchasesService) private var purchasesService
    @Injected(Container.subscriptionSyncService) private var subscriptionsService
    @Injected(Container.analyticsService) private var analyticsService
    @Injected(Container.appStatsService) private var appStatsService
    @Injected(Container.paywallProductsConverter) private var paywallProductsConverter

    let benefits: [String] = [
        "paywallBenefits1",
        "paywallBenefits2",
        "paywallBenefits3",
        "paywallBenefits4"
    ]
    let out: PaywallViewOut
    private(set) var shouldShowKaspi: Bool = false

    init(out: @escaping PaywallViewOut) {
        self.out = out
        self.shouldShowKaspi = appStatsService.showsRI && [Language.kz, Language.ru].contains(LocalizationService.shared.language)
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
                print(products.map { $0.appStoreId })
                self.products = paywallProductsConverter.convertByExpensive(products: products)
                print(self.products.map { $0.product.appStoreId })
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
        analyticsService.trackSelectPaywallProduct(id: product.product.appStoreId)
        purchase()
    }

    func purchase() {
        hapticLight()
        guard let selectedProduct else { return }
        shouldShowLoader = true
        analyticsService.trackSubscription(productId: selectedProduct.product.appStoreId, price: selectedProduct.prettyPrice)
        Task {
            do {
                setButtonLoading(to: true)
                let isSuccessful = try await purchasesService.purchase(product: selectedProduct.product.product)
                subscriptionsService.updateSubscriptionStatus(to: isSuccessful)
                error = nil
                setButtonLoading(to: false)
                if isSuccessful {
                    state = .purchaseSuccess
                    analyticsService.trackSubscriptionSuccess(productId: selectedProduct.product.appStoreId, price: selectedProduct.prettyPrice)
                }
                shouldShowLoader = false
            } catch let error as PurchasesError {
                shouldShowLoader = false
                self.error = error
                setButtonLoading(to: false)
//                state = .failed(error)
                analyticsService.trackSubscriptionError(productId: selectedProduct.product.appStoreId, error: error.localizedDescription)
            }
        }
    }

    func payKaspi() {
        analyticsService.trackPayKaspi()
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
