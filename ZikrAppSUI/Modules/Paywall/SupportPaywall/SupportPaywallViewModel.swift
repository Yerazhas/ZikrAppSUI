//
//  SupportPaywallViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 18.08.2023.
//

import Foundation
import Factory
import Qonversion

@MainActor
final class SupportPaywallViewModel: ObservableObject, LoadingButtonViewModel {
    enum State {
        case loading
        case loaded
        case failed(Error)
    }
    @Injected(Container.purchasesService) private var purchasesService
    @Injected(Container.analyticsService) private var analyticsService
    @Published private(set) var products: [PurchasingProduct] = []
    @Published var state: State = .loading
    @Published var isButtonLoading: Bool = false
    @Published private(set) var selectedProduct: PurchasingProduct?
    let completion: () -> Void

    init(completion: @escaping () -> Void) {
        self.completion = completion
    }

    func onAppear() {
        Task {
            do {
                self.state = .loading
                self.products = try await purchasesService.getProducts(offeringId: QonversionOffering.paywallSupport.rawValue)
                self.selectedProduct = self.products.dropLast().dropLast().last
                self.state = .loaded
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func selectProduct(_ product: PurchasingProduct) {
        hapticLight()
        selectedProduct = product
    }

    func purchase() {
        guard let selectedProduct else { return }
        analyticsService.trackDonation(productId: selectedProduct.appStoreId)
        Task {
            do {
                setButtonLoading(to: true)
                let isSuccessful = try await purchasesService.purchase(product: selectedProduct.product)
                setButtonLoading(to: false)
                if isSuccessful {
                    completion()
                    analyticsService.trackDonationSuccess(productId: selectedProduct.appStoreId)
                }
            } catch {
                setButtonLoading(to: false)
                analyticsService.trackDonationError(productId: selectedProduct.appStoreId, error: error.localizedDescription)
            }
        }
    }
}

extension SupportPaywallViewModel: Hapticable {}
