//
//  QonversionPurchasesService.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 14.08.2023.
//

import Qonversion
import Factory

enum QonversionOffering: String {
    case main = "paywall_1"
    case paywallSupport = "paywall_support"
}

final class QonversionPurchasesServiceImpl: PurchasesService {
    private(set) var products: [Qonversion.Product] = []

    func getProducts(offeringId: QonversionOffering) async throws -> [Qonversion.Product] {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            Qonversion.shared().offerings { offerings, error in
                if let error {
                    let fetchProductsError = PurchasesError.fetchProductsError(underlying: error)
                    continuation.resume(throwing: fetchProductsError)
                    return
                }
                if let products = offerings?.offering(for: offeringId.rawValue)?.products {
                    if products.isEmpty {
                        let noProductsError = PurchasesError.noProducts
                        continuation.resume(throwing: noProductsError)
                        return
                    }
                    self?.products = products
                    continuation.resume(returning: products)
                } else {
                    let noProductsError = PurchasesError.noProducts
                    continuation.resume(throwing: noProductsError)
                }
            }
        }
    }

    func purchase(product: Qonversion.Product) async throws -> Bool {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
            Qonversion.shared().purchaseProduct(product) { entitlements, error, isCancelled in
                if isCancelled {
                    let cancelError = PurchasesError.cancelled
                    continuation.resume(throwing: cancelError)
                    return
                }
                if let error = error {
                    let purchaseError = PurchasesError.purchaseError(underlying: error)
                    continuation.resume(throwing: purchaseError)
                    return
                }
                if let premium: Qonversion.Entitlement = entitlements["Premium"] {
                    continuation.resume(returning: premium.isActive)
                } else {
                    continuation.resume(returning: false)
                }
            }
        }
    }

    func checkSubscription() async throws -> Bool {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
            Qonversion.shared().checkEntitlements { entitlements, error in
                if let error = error {
                    let purchaseError = PurchasesError.purchaseError(underlying: error)
                    continuation.resume(throwing: purchaseError)
                    return
                }
                if let premium: Qonversion.Entitlement = entitlements["Premium"], premium.isActive {
                    switch premium.renewState {
                    case .willRenew, .nonRenewable:
                        // .willRenew is the state of an auto-renewable subscription
                        // .nonRenewable is the state of consumable/non-consumable IAPs that could unlock lifetime access
                        continuation.resume(returning: true)
                        return
                    case .billingIssue:
                        // Grace period: entitlement is active, but there was some billing issue.
                        // Prompt the user to update the payment method.

                        continuation.resume(returning: false) // fix to handle billing issues
                        return
                    case .cancelled:
                        // The user has turned off auto-renewal for the subscription, but the subscription has not expired yet.
                        // Prompt the user to resubscribe with a special offer.
                        continuation.resume(returning: true)
                        return
                    default:
                        continuation.resume(returning: false)
                        return
                    }
                } else {
                    continuation.resume(returning: false)
                    return
                }
            }
        }
    }

    func restorePurchases() async throws -> Bool {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
            Qonversion.shared().restore { [weak self] (entitlements, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                if let entitlement: Qonversion.Entitlement = entitlements["Premium"], entitlement.isActive {
                    continuation.resume(returning: true)
                    return
                } else {
                    continuation.resume(returning: false)
                    return
                }
            }
        }
    }
}

extension Container {
    static let purchasesService = Factory<PurchasesService>(scope: .singleton) {
        QonversionPurchasesServiceImpl()
    }
}


public enum PurchasesError: Error {
    case networkError
    case cancelled
    case noProducts
    case unauthorized
    case fetchProductsError(underlying: Error)
    case checkTrialEligibilityError(underlying: Error)
    case purchaseError(underlying: Error)
    case checkPermissionsError(underlying: Error?)
    case restorationError(underlying: Error?)
    
    var localizedDescription: String {
        switch self {
        case .networkError:
            return "PurchasesError.networkError"
        case .cancelled:
            return "PurchasesError.cancelled"
        case .noProducts:
            return "PurchasesError.noProducts"
        case .unauthorized:
            return "PurchasesError.unauthorized"
        case let .fetchProductsError(error):
            return "PurchasesError.fetchProductsError. Underlying: \(error.localizedDescription)"
        case let .checkTrialEligibilityError(error):
            return "PurchasesError.checkTrialEligibilityError. Underlying: \(error.localizedDescription)"
        case let .purchaseError(error):
            return "PurchasesError.purchaseError. Underlying: \(error.localizedDescription)"
        case let .checkPermissionsError(error):
            var description = "PurchasesError.checkPermissionsError."
            if let error = error {
                description += " Underlying: \(error.localizedDescription)"
            }
            return description
        case let .restorationError(error):
            var description = "PurchasesError.restorationError."
            if let error = error {
                description += " Underlying: \(error.localizedDescription)"
            }
            return description
        }
    }
}

extension Qonversion.Product {
    var localizedPeriod: String? {
        if type == .oneTime {
            return "Lifetime"
        } else {
            return skProduct?.subscriptionPeriod?.periodString
        }
    }

    var subscriptionDescription: String? {
        if type == .oneTime {
            return "One-time payment"
        } else {
            return skProduct?.subscriptionPeriod?.subscriptionDescription
        }
    }
}
