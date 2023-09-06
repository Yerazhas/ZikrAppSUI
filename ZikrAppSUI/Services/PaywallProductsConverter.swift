//
//  PaywallProductsConverter.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 03.09.2023.
//

import Factory
import Qonversion

final class PaywallProductsConverter {
    func convertByExpensive(products: [Qonversion.Product]) -> [PaywallProduct] {
        let hasMoreThan2Products = products.count > 2

        if products.isEmpty {
            return []
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2

        if let product = products.first {
            formatter.locale = product.skProduct?.priceLocale
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
            
            if product.storeID != mostExpensiveProduct?.storeID,
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
            return PaywallProduct(product: product, fullPrice: fullPrice, isMostPopular: isMostPopular, discount: discount)
        }
    }
}

extension Container {
    static let paywallProductsConverter = Factory<PaywallProductsConverter> {
        .init()
    }
}

struct PaywallProduct {
    let localizedPeriod: String
    let duration: Qonversion.ProductDuration
    let prettyPrice: String
    let subtitle: String?
    let isMostPopular: Bool
    let fullPrice: String?
    let discount: String?
    let product: Qonversion.Product

    init(
        product: Qonversion.Product,
        fullPrice: String?,
        isMostPopular: Bool = false,
        discount: String?
    ) {
        self.product = product
        localizedPeriod = product.localizedPeriod ?? ""
        duration = product.duration
        prettyPrice = product.prettyPrice
        subtitle = product.subscriptionDescription
        self.isMostPopular = isMostPopular
        self.fullPrice = fullPrice
        self.discount = discount
    }
}

extension PaywallProduct: Equatable {
    static func == (_ lhs: PaywallProduct, _ rhs: PaywallProduct) -> Bool {
        lhs.product.storeID == rhs.product.storeID
    }
}

extension Qonversion.Product {
    public var dailyPrice: NSDecimalNumber? {
        guard let durationInDays = duration.inDays else {
            return nil
        }
        let behavior = NSDecimalNumberHandler(
            roundingMode: .down,
            scale: 2,
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false
        )

        return skProduct?.price.dividing(
            by: NSDecimalNumber(decimal: Decimal(durationInDays)),
            withBehavior: behavior
        )
    }
}

extension Qonversion.ProductDuration {
    public var inDays: Int? {
        switch self {
        case .durationWeekly:
            return 7
        case .durationMonthly:
            return 30
        case .duration3Months:
            return 30 * 3
        case .duration6Months:
            return 30 * 6
        case .durationAnnual:
            return 365
        case .durationLifetime, .durationUnknown:
            return nil
        }
    }
}
