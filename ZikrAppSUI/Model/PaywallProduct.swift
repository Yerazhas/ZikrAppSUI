//
//  PaywallProduct.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 06.11.2023.
//

import Qonversion

struct PaywallProduct {
    let localizedPeriod: String
    let duration: PurchasingProduct.Duration
    let prettyPrice: String
    let subtitle: String?
    let isMostPopular: Bool
    let fullPrice: String?
    let hasTrial: Bool
    let discount: String?
    let product: PurchasingProduct

    init(
        product: PurchasingProduct,
        fullPrice: String?,
        hasTrial: Bool,
        isMostPopular: Bool = false,
        discount: String?
    ) {
        self.product = product
        localizedPeriod = product.duration.stringValue ?? ""
        duration = product.duration
        prettyPrice = product.prettyPrice
        subtitle = product.subscriptionDescription
        self.isMostPopular = isMostPopular
        self.fullPrice = fullPrice
        self.discount = discount
        self.hasTrial = hasTrial
    }

    func getTitle(language: Language) -> String {
        if let trialDurationString = product.trialDuration.stringValue {
            return "\(trialDurationString.localized(language)) + \("\(product.localizedPeriod ?? "")".localized(language))"
        } else {
            return "ZikrApp \("\(product.localizedPeriod ?? "")".localized(language))"
        }
    }

    func getMultipliedPrice(by amount: NSDecimalNumber) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        let price = product.price
        return formatter.string(from: price.multiplying(by: amount))
    }
}

extension PaywallProduct: Equatable {
    static func == (_ lhs: PaywallProduct, _ rhs: PaywallProduct) -> Bool {
        lhs.product.appStoreId == rhs.product.appStoreId
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
