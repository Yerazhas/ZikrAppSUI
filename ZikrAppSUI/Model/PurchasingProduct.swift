//
//  PurchasingProduct.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 06.11.2023.
//

import Foundation
import Qonversion

public struct PurchasingProduct: Equatable {
    public enum Duration: Int {
        case unknown
        case monthly
        case annual
        case lifetime

        public var stringValue: String? {
            switch self {
            case .monthly:
                return "monthly"
            case .annual:
                return "yearly"
            case .unknown, .lifetime:
                return "lifetime"
            }
        }

        public var inDays: Int? {
            switch self {
            case .monthly:
                return 30
            case .annual:
                return 365
            case .lifetime, .unknown:
                return nil
            }
        }
    }

    public enum TrialDuration {
        case notAvailable
        case threeDays
        case week

        public var inDays: Int? {
            switch self {
            case .threeDays:
                return 3
            case .week:
                return 7
            case .notAvailable:
                return nil
            }
        }

        public var stringValue: String? {
            switch self {
            case .threeDays:
                return "trial3Days"
            case .week:
                return "trialWeek"
            case .notAvailable:
                return nil
            }
        }
    }

    public enum ProductType {
        case unknown
        case trial
        case directSubscription
        case oneTime
    }

    public let id: String
    public let appStoreId: String
    public let price: NSDecimalNumber
    let prettyPrice: String
    let product: Qonversion.Product
    let priceLocale: Locale?

    public let duration: Duration
    public let localizedDuration: String?

    public let trialDuration: TrialDuration
    // changed to var because of being used from QonversionPurchasesService
    public var localizedTrialDuration: String?

    public let type: ProductType
    public let locale: Locale?

    // changed to var because of being used from QonversionPurchasesService
    public var introductoryPrice: NSDecimalNumber?

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

        return price.dividing(
            by: NSDecimalNumber(decimal: Decimal(durationInDays)),
            withBehavior: behavior
        )
    }

    public var localizedTitle: String {
        let title: String
        switch duration {
        case .monthly:
            title = "monthly"
        case .annual:
            title = "yearly"
        case .lifetime, .unknown:
            title = "lifetime"
        }
        return title
    }
}

extension PurchasingProduct {
    init(
        qonversionProduct: Qonversion.Product,
        introEligibility: Qonversion.IntroEligibility?
    ) {
        product = qonversionProduct
        id = qonversionProduct.qonversionID
        appStoreId = qonversionProduct.skProduct?.productIdentifier ?? ""
        price = qonversionProduct.skProduct?.price ?? 0
        prettyPrice = qonversionProduct.prettyPrice
        locale = qonversionProduct.skProduct?.priceLocale ?? .current
        localizedDuration = qonversionProduct.skProduct?.subscriptionPeriod?.localizedPeriod
        priceLocale = qonversionProduct.skProduct?.priceLocale

        switch qonversionProduct.duration {
        case .durationUnknown:
            duration = .unknown
        case .durationMonthly:
            duration = .monthly
        case .durationAnnual:
            duration = .annual
        default:
            duration = .lifetime
        }

        if introEligibility?.status == .nonIntroProduct || introEligibility?.status == .ineligible {
            trialDuration = .notAvailable
        } else {
            introductoryPrice = qonversionProduct.skProduct?.introductoryPrice?.price
            localizedTrialDuration = qonversionProduct.skProduct?.introductoryPrice?.subscriptionPeriod.localizedPeriod

            switch qonversionProduct.trialDuration {
            case .threeDays:
                trialDuration = .threeDays
            case .week:
                trialDuration = .week
            default:
                trialDuration = .notAvailable
            }
        }

        switch qonversionProduct.type {
        case .unknown:
            type = .unknown
        case .trial:
            type = .trial
        case .directSubscription:
            type = .directSubscription
        case .oneTime:
            type = .oneTime
        }
    }
}
