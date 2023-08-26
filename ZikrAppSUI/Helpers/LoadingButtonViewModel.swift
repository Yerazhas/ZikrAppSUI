//
//  LoadingButtonViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 15.08.2023.
//

import SwiftUI

public protocol LoadingButtonViewModel: AnyObject {
    var isButtonLoading: Bool { get set }
    func setButtonLoading(to isLoading: Bool) // to change button loader state with animation
}

public extension LoadingButtonViewModel {
    func setButtonLoading(to isLoading: Bool) {
        withAnimation {
            DispatchQueue.main.async {
                self.isButtonLoading = isLoading
            }
        }
    }
}
