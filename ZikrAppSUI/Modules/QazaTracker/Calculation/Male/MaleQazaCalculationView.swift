//
//  MaleQazaCalculationView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 08.10.2023.
//

import SwiftUI
import UIKit

struct MaleQazaCalculationView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    @ObservedObject var viewModel: MaleProfileDetailsFillOutViewModel

    var body: some View {
        VStack(spacing: 5) {
            // MARK: - Birth date
            TitledDateInputView(viewModel: viewModel.birthdayDateViewModel)
            //MARK: - Majority date
            TitledStepperView(title: "majorityAge".localized(language),
                              quantity: $viewModel.majorityAge)
            RadioButtonView(flag: $viewModel.isMajorityDateUnknown,
                            title: "dontKnow".localized(language))
            WarningView(text: "majorityAgeWarningTitle".localized(language))
            // MARK: - Prayer start date
            TitledDateInputView(viewModel: viewModel.prayerStartDateViewModel)
            RadioButtonView(flag: $viewModel.isPrayerStartDateToday,
                            title: "sinceToday".localized(language))
            // MARK: - Safar days
            TitledStepperView(title: "safarDays".localized(language),
                              quantity: $viewModel.safarDaysCount)
        }
        .alert(isPresented: $viewModel.shouldShowError) {
            Alert(error: viewModel.error ?? .unknownError)
        }
    }
}

struct RadioButtonView: View {
    @Binding var flag: Bool
    let title: String
    
    var body: some View {
        HStack {
            Button {
                hapticLight()
                flag.toggle()
            } label: {
                if flag {
                    Image(systemName: "circle.inset.filled").renderingMode(.original)
                } else {
                    Image(systemName: "circle").renderingMode(.original)
                }
            }
            Text(title)
                .font(.footnote)
                .fontWeight(.light)
            Spacer()
        }.padding(EdgeInsets(top: 0,
                             leading: 15,
                             bottom: 0,
                             trailing: 15))
    }
}

extension RadioButtonView: Hapticable {}

struct TitledDateInputView: View {
    @ObservedObject var viewModel: TitledDateInputViewModel
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-YY"
        
        return dateFormatter
    }()
    
    var body: some View {
        VStack {
            HStack {
                Text(viewModel.title)
                    .font(.subheadline)
                    .fontWeight(.light)
                Spacer()
            }
            DatePickerInputView(date: $viewModel.date,
                                placeholder: viewModel.placeholder)
                .disabled(!viewModel.isEnabled)
                .padding(EdgeInsets(top: 10,
                                    leading: 10,
                                    bottom: 10,
                                    trailing: 10))
                .background(Color.paleGray)
                .cornerRadius(5)
        }
        .padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
    }
    
}

struct DatePickerInputView: UIViewRepresentable {
    @Binding var date: Date?
    let placeholder: String
    
    init(date: Binding<Date?>, placeholder: String) {
        self._date = date
        self.placeholder = placeholder
    }
    
    func updateUIView(_ uiView: DatePickerTextField, context: Context) {
        uiView.text = date?.string
    }
    
    func makeUIView(context: Context) -> DatePickerTextField {
        let dptf = DatePickerTextField(date: $date, frame: .zero)
        dptf.placeholder = placeholder.localized(LocalizationService.shared.language)
        dptf.text = date?.string
        
        return dptf
    }
    
}

final class DatePickerTextField: UITextField {
    @Binding var date: Date?
    private let datePicker = UIDatePicker()
    
    init(date: Binding<Date?>, frame: CGRect) {
        self._date = date
        super.init(frame: frame)
        inputView = datePicker
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.addTarget(self, action: #selector(datePickerDidSelect(_:)), for: .valueChanged)
        datePicker.datePickerMode = .date
        datePicker.locale = .init(identifier: LocalizationService.shared.language.rawValue)
        datePicker.maximumDate = Date()
        if let date = date.wrappedValue {
            datePicker.date = date
        }
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "close".localized(LocalizationService.shared.language), style: .plain, target: self, action: #selector(dismissTextField))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        inputAccessoryView = toolBar
        
        font = .systemFont(ofSize: 16, weight: .light)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func datePickerDidSelect(_ sender: UIDatePicker) {
        date = sender.date
    }
    
    @objc private func dismissTextField() {
        resignFirstResponder()
    }
    
}

extension Alert {
    init(error: LocalizedError) {
        let language = LocalizationService.shared.language
        self.init(title: Text((error.errorDescription ?? "").localized(language)),
                  message: Text((error.failureReason ?? "").localized(language)),
                  dismissButton: .default(Text("ok".localized(language))))
    }
}
