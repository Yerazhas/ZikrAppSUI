//
//  ZikrTapViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 17.01.2023.
//

import Foundation
import Factory

final class ZikrTapViewModel: ObservableObject, Hapticable {
    @Published private(set) var count: Int = 0
    @Published private(set) var totalCount: Int
    @Injected(Container.analyticsService) private var analyticsService
    private let zikrService = ZikrService()
    let zikr: Zikr
    private let out: () -> Void

    init(zikr: Zikr, out: @escaping () -> Void) {
        self.zikr = zikr
        self.out = out
        totalCount = zikr.totalDoneCount
        NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: .main) { _ in
            self.willDisappear()
        }
    }

    func zikrDidTap() {
        hapticLight()
        count += 1
        totalCount += 1
    }

    func reset() {
        hapticStrong()
        count = 0
    }

    func onAppear() {
        analyticsService.trackOpenZikr(zikr: zikr)
    }

    func willDisappear() {
        zikrService.updateZikrTotalCount(type: zikr.type, id: zikr.id, totalCount: totalCount)
        analyticsService.trackCloseZikr(zikr: zikr, count: count)
        out()
    }
}
