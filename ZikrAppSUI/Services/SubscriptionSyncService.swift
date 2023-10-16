//
//  SubscriptionSyncService.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 16.08.2023.
//

import Foundation
import Factory

public protocol SubscriptionSyncService {
    var isSubscribed: Bool { get }
    var isSubscribedPublisher: Published<Bool>.Publisher { get }
    func updateSubscriptionStatus(to isSubscribed: Bool)
}

final class SubscriptionSyncServiceImpl: SubscriptionSyncService {
    @UserDefaultsValue(key: "SubscriptionSyncServiceIsSubscribed", defaultValue: false)
    private var tempIsSubscribed: Bool

    @Published private(set) var isSubscribed: Bool = false
    var isSubscribedPublisher: Published<Bool>.Publisher {
        $isSubscribed
    }

    init() {
        isSubscribed = tempIsSubscribed
    }

    func updateSubscriptionStatus(to isSubscribed: Bool) {
        self.tempIsSubscribed = isSubscribed
        self.isSubscribed = isSubscribed
//        self.tempIsSubscribed = true
//        self.isSubscribed = true
    }
}

extension Container {
    static let subscriptionSyncService = Factory<SubscriptionSyncService>(scope: .singleton) {
        SubscriptionSyncServiceImpl()
    }
}
