//
//  LottieProgressViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 11.10.2023.
//

import Foundation

@MainActor
final class LottieProgressViewModel: ObservableObject {
    let completion: (() -> Void)?

    init(completion: (() -> Void)?) {
        self.completion = completion
        load()
    }

    func load() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.completion?()
        }
    }
}
