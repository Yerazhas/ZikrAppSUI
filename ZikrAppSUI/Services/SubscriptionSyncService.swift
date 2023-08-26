//
//  SubscriptionSyncService.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 16.08.2023.
//

import Foundation
import Factory

public protocol SubscriptionSyncService {
    var isSubscrtibed: Bool { get }
    func updateSubscriptionStatus(to isSubscribed: Bool)
}

final class SubscriptionSyncServiceImpl: SubscriptionSyncService {
    @UserDefaultsValue(key: "SubscriptionSyncServiceIsSubscribed", defaultValue: false)
    private var _isSubscribed: Bool

    var isSubscrtibed: Bool {
        _isSubscribed
    }
    
    func updateSubscriptionStatus(to isSubscribed: Bool) {
        self._isSubscribed = isSubscribed
    }
}

extension Container {
    static let subscriptionSyncService = Factory<SubscriptionSyncService>(scope: .singleton) {
        SubscriptionSyncServiceImpl()
    }
}
