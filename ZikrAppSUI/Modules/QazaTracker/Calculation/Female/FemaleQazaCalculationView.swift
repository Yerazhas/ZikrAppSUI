//
//  FemaleQazaCalculationView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 08.10.2023.
//

import SwiftUI

struct FemaleQazaCalculationView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    @ObservedObject var viewModel: FemaleProfileDetailsFillOutViewModel
    
    var body: some View {
        VStack {
            // MARK: - Birth date
            TitledDateInputView(viewModel: viewModel.birthdayDateViewModel)
            //MARK: - Majority date
            TitledStepperView(title: "majorityAge".localized(language),
                              quantity: $viewModel.majorityAge)
            RadioButtonView(flag: $viewModel.isMajorityDateUnknown, title: "dontKnow".localized(language))
            WarningView(text: "majorityAgeWarningTitle".localized(language))
            // MARK: - Prayer start date
            TitledDateInputView(viewModel: viewModel.prayerStartDateViewModel)
            RadioButtonView(flag: $viewModel.isPrayerStartDateToday, title: "sinceToday".localized(language))
            // MARK: - Safar days
            TitledStepperView(title: "safarDays".localized(language),
                              quantity: $viewModel.safarDaysCount)
            // MARK: - Haid days
            TitledStepperView(title: "monthlyHaidDays".localized(language),
                              quantity: $viewModel.haidDaysCount)
            // MARK: - Childbirth count
            TitledStepperView(title: "birthAmountBeforePrayerStart".localized(language),
                              quantity: $viewModel.childBirthCount)
        }
        .alert(isPresented: $viewModel.shouldShowError) {
            Alert(error: viewModel.error ?? .unknownError)
        }
    }
}

//#Preview {
//    FemaleQazaCalculationView(viewModel: .init(completion: {}))
//}
