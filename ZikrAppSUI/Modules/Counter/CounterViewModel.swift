//
//  CounterViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 16.01.2023.
//

import SwiftUI
import Factory

final class CounterViewModel: ObservableObject, Hapticable {
    @AppStorage("counterCount") private(set) var count: Int = 0
    @Injected(Container.analyticsService) private var analyticsService

    func zikrDidTap() {
        hapticLight()
        count += 1
    }

    func reset() {
        hapticStrong()
        count = 0
    }

    func onAppear() {
        analyticsService.trackOpenCounter(count: count)
    }

    func onDisappear() {
        analyticsService.trackCloseCounter(count: count)
    }
}
