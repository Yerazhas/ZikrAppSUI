//
//  AppConfiguration.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 11.09.2023.
//

import Foundation

///https://stackoverflow.com/questions/26081543/how-to-tell-at-runtime-whether-an-ios-app-is-running-through-a-testflight-beta-i/26113597#26113597
public enum AppConfiguration: String {
    case debug = "Debug"
    case testFlight = "TestFlight"
    case appStore = "AppStore"

    private static let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"

    public static var current: AppConfiguration {
        #if DEBUG
            return .debug
        #endif

        if isTestFlight {
            return .testFlight
        } else {
            return .appStore
        }
    }
}

