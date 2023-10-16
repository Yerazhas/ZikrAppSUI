//
//  QazaManualEnterView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 08.10.2023.
//

import SwiftUI

struct QazaManualInputView: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("language") private var language = LocalizationService.shared.language
    @StateObject private var viewModel: QazaManualInputViewModel

    init(completion: @escaping () -> Void) {
        _viewModel = .init(wrappedValue: .init(completion: completion))
    }

    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.black : Color.white)
                .ignoresSafeArea(.all)
            ScrollView(.vertical) {
                VStack(alignment: .center) {
                    VStack(spacing: 5) {
                        Text("manualFillOutTitle".localized(language))
                            .font(.title2)
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        WarningView(text: "manualFillOutWarning".localized(language))
                        Divider()
                            .padding(.top, 20)
                    }
                    .padding(.top, 20)
                    Spacer()
                    ForEach(0..<viewModel.qazaInputRowViewModels.count) { index in
                        let inputRowVM = viewModel.qazaInputRowViewModels[index]
                        PrayerCheckoutRowView(viewModel: inputRowVM)
                    }
                    Spacer()
                        .frame(width: 0,
                                   height: 44,
                                   alignment: .center)
                    Button(action: {
                        viewModel.saveUser()
                    }) {
                        ZStack {
//                            Color(hex: "#A6C053")
                            Color.systemGreen
//                                .opacity(0.5)
                                .cornerRadius(10)
                            Text("save".localized(language))
                                .bold()
                                .foregroundColor(colorScheme == .light ? .white : .black)
                        }
                    }
                    .padding(.horizontal)
                    .frame(height: 50)
                    Spacer().frame(width: 0,
                                   height: 50,
                                   alignment: .center)
                }
            }
        }
    }
}

#Preview {
    QazaManualInputView {}
}
