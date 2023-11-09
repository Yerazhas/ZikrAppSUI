//
//  PrayerCheckoutRowView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 08.10.2023.
//

import SwiftUI
import UIKit

struct PrayerCheckoutRowView: View {
    @StateObject var viewModel: PrayerAmountRowViewModel

    var body: some View {
        TitledStepperView(title: viewModel.title, quantity: $viewModel.count, isEditable: viewModel.isEditable)
    }
}

//#Preview {
//    PrayerCheckoutRowView(viewModel: .init(count: 0, title: "Default"))
//}

struct TitledStepperView: View {
    let title: String
    @Binding var quantity: Int
    var isEditable = true
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.light)
                Spacer()
            }
            Stepper(onIncrement: {
                self.increment()
            }, onDecrement: {
                self.decrement()
            }) {
                ClosableTextFieldView(text: Binding<String?>(get: { "\(self.quantity)" },
                                                             set: { self.quantity = Int($0 ?? "") ?? 0 }),
                                      placeholder: "")
                    .disabled(!isEditable)
                    .padding(EdgeInsets(top: 10,
                                        leading: 10,
                                        bottom: 10,
                                        trailing: 10))
                    .background(Color.paleGray)
                    .cornerRadius(5)
            }
        }
        .padding(EdgeInsets(top: 5,
                             leading: 15,
                             bottom: 5,
                             trailing: 15))
    }
    
    private func increment() {
        hapticLight()
        quantity += 1
    }
    
    private func decrement() {
        if quantity > 0 {
            hapticLight()
            quantity -= 1
        } else {
            hapticStrong()
        }
    }
    
}

extension TitledStepperView: Hapticable {}

struct ClosableTextFieldView: UIViewRepresentable {
    @Binding var text: String?
    
    let placeholder: String
    
    init(text: Binding<String?>, placeholder: String) {
        self._text = text
        self.placeholder = placeholder
    }
    
    func updateUIView(_ uiView: ClosableTextField, context: Context) {
        uiView.text = text
    }
    
    func makeUIView(context: Context) -> ClosableTextField {
        let ctf = ClosableTextField(text: $text, frame: .zero)
        ctf.placeholder = placeholder
        ctf.text = text
        
        return ctf
    }
    
}

final class ClosableTextField: UITextField {
    @Binding var textValue: String?
    
    init(text: Binding<String?>, frame: CGRect) {
        self._textValue = text
        super.init(frame: frame)
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Закрыть", style: .plain, target: self, action: #selector(dismissTextField))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        inputAccessoryView = toolBar
        addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        keyboardType = .decimalPad
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        textValue = textField.text
    }
    
    @objc private func dismissTextField() {
        resignFirstResponder()
    }
    
}
