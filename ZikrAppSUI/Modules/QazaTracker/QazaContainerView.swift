//
//  QazaContainerView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 08.10.2023.
//

import SwiftUI
import Factory

struct QazaContainerView: View {
    @StateObject private var viewModel: QazaContainerViewModel
    @AppStorage(.didSetUpQaza) private var didSetUpQaza = false
    private let out: QazaTrackerOut

    init(out: @escaping QazaTrackerOut) {
        self.out = out
        _viewModel = .init(wrappedValue: .init())
    }

    var body: some View {
        Group {
            if didSetUpQaza {
                QazaTrackerView(out: out)
            } else {
                QazaInputSelectionView()
            }
        }
        .navigationBarHidden(true)
    }
}

final class QazaContainerViewModel: ObservableObject {
    @Injected(Container.appStatsService) private var appStatsService
    @Published var didInput: Bool = false
}
