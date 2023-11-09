//
//  PurchasesService.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 14.08.2023.
//

import Foundation
import Qonversion

protocol PurchasesService {
    var products: [PurchasingProduct] { get }
    func getProducts(offeringId: String) async throws -> [PurchasingProduct]
    func getRemoteConfig() async throws -> Qonversion.RemoteConfig
    func purchase(product: Qonversion.Product) async throws -> Bool
    func checkSubscription() async throws -> Bool
    func restorePurchases() async throws -> Bool
}
