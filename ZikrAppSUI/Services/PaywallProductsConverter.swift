//
//  PaywallProductsConverter.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 03.09.2023.
//

import Factory
import Qonversion

final class PaywallProductsConverter {
    func convertByExpensive(products: [PurchasingProduct]) -> [PaywallProduct] {
        if products.isEmpty {
            return []
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2

        if let product = products.first {
            formatter.locale = product.priceLocale
        }

        let mostExpensiveProduct = products.filter { $0.type != .oneTime}.sorted { lhs, rhs in
            guard let lhsPrice = lhs.dailyPrice, let rhsPrice = rhs.dailyPrice else {
                return false
            }
            return lhsPrice.compare(rhsPrice) == .orderedDescending
        }.first

        return products.map { product in
            var discount: String?
            var fullPrice: String?
            var isMostPopular: Bool = false
            
            if product.appStoreId != mostExpensiveProduct?.appStoreId,
               product.type != .oneTime,
               let durationInDays = product.duration.inDays,
               let mostExpensiveDailyPrice = mostExpensiveProduct?.dailyPrice,
               let dailyPrice = product.dailyPrice {
                let discontPercent = Int(
                    NSDecimalNumber(100)
                        .subtracting(dailyPrice.dividing(by: mostExpensiveDailyPrice).multiplying(by: 100))
                        .floatValue
                )
                discount = "\(discontPercent)%"
                isMostPopular = true
                fullPrice = formatter
                    .string(from: mostExpensiveDailyPrice.multiplying(by: NSDecimalNumber(value: durationInDays)))
            }
            return PaywallProduct(
                product: product,
                fullPrice: fullPrice,
                hasTrial: product.trialDuration != .notAvailable,
                isMostPopular: isMostPopular,
                discount: discount
            )
        }
    }
}

extension Container {
    static let paywallProductsConverter = Factory<PaywallProductsConverter> {
        .init()
    }
}
