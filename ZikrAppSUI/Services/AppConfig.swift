//
//  AppConfig.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 12.09.2023.
//

import Foundation

struct AppConfig: Decodable {
    let should_sri: Bool
    let is_lifetime_activation_available: Bool
    let paywall: String
}
