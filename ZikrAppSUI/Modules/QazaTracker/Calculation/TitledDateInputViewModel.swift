//
//  TitledDateInputViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 08.10.2023.
//

import Foundation

final class TitledDateInputViewModel: ObservableObject {
    @Published var text: String?
    @Published var shouldShowDatePicker = false
    @Published var date: Date?
    @Published var isEnabled: Bool
    var title: String
    var placeholder: String
    
    init(title: String, placeholder: String, isEnabled: Bool = true) {
        self.title = title
        self.placeholder = placeholder
        self.isEnabled = isEnabled
    }
}
