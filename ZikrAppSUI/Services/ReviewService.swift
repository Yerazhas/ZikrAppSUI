//
//  ReviewService.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 04.02.2023.
//

import Foundation
import SwiftUI
import StoreKit

final class ReviewService {
    static let shared = ReviewService()
    @AppStorage ("skyapps_review_last_version") var lastVersionRequestedForReview: String?
    @AppStorage ("requestsCount") var requestsCount: Int = 0

    func requestReviewIfPossible() {
        guard self.canReviewBeRequested() else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) { [weak self] in
            self?.requestReview()
        }
    }

    private func canReviewBeRequested() -> Bool {
        guard
            let currentVersion = self.currentVersion,
            currentVersion != self.lastVersionRequestedForReview
        else { return false }
        return true
    }

    private func requestReview() {
        guard let currentVersion = self.currentVersion else { return }
        guard requestsCount >= 4 else {
            requestsCount += 1
            return
        }
        SKStoreReviewController.requestReview()
        self.lastVersionRequestedForReview = currentVersion
    }

    private var currentVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
    }
}
