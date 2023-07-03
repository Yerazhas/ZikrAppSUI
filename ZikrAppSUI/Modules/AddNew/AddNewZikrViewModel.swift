//
//  AddNewZikrViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 02.07.2023.
//

import Foundation
import Combine

final class AddNewZikrViewModel: ObservableObject, Identifiable {
    let zikr: Zikr
    var id: String {
        zikr.type.rawValue + zikr.title
    }
    @Published private(set) var isSelected: Bool = false
    var targetAmount: Int {
        Int(textFieldViewModel.value) ?? 10
    }

    private(set) lazy var textFieldViewModel: ValidatedTextFieldViewModel = {
        ValidatedTextFieldViewModel(
            value: "33",
            placeholder: "",
            errorMessage: "",
            onSubmitAction: {},
            validation: { _ in return true },
            onStateChangeAction: { [weak self] state in
                guard let self else { return }
//                self.isButtonActive = state == .valid && self.emailViewModel.state  == .valid
            }
        )
    }()

    init(zikr: Zikr) {
        self.zikr = zikr
    }

    func toggleSelection() {
        isSelected.toggle()
    }
}
