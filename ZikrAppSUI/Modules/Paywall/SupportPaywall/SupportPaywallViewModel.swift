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
    @Published private(set) var products: [Qonversion.Product] = []
    @Published var state: State = .loading
    @Published var isButtonLoading: Bool = false
    @Published private(set) var selectedProduct: Qonversion.Product?
    let completion: () -> Void

    init(completion: @escaping () -> Void) {
        self.completion = completion
    }

    func onAppear() {
        Task {
            do {
                self.state = .loading
                self.products = try await purchasesService.getProducts(offeringId: .paywallSupport)
                self.selectedProduct = self.products.dropLast().dropLast().last
                self.state = .loaded
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func selectProduct(_ product: Qonversion.Product) {
        hapticLight()
        selectedProduct = product
    }

    func purchase() {
        guard let selectedProduct else { return }
        analyticsService.trackDonation(productId: selectedProduct.storeID)
        Task {
            do {
                setButtonLoading(to: true)
                let isSuccessful = try await purchasesService.purchase(product: selectedProduct)
                setButtonLoading(to: false)
                if isSuccessful {
                    completion()
                    analyticsService.trackDonationSuccess(productId: selectedProduct.storeID)
                }
            } catch {
                setButtonLoading(to: false)
                analyticsService.trackDonationError(productId: selectedProduct.storeID, error: error.localizedDescription)
            }
        }
    }
}

extension SupportPaywallViewModel: Hapticable {}
