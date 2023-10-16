//
//  QazaCalculationView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 08.10.2023.
//

import SwiftUI

struct QazaCalculationView: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("language") private var language = LocalizationService.shared.language
    @ObservedObject var viewModel: QazaCalculationViewModel

    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.black : Color.white)
                .ignoresSafeArea(.all)
            ScrollView {
                VStack(alignment: .center) {
                    
                    // MARK: - Info Header -
                    
                    VStack(spacing: 5) {
                        Text("fillOutInfo.title".localized(language))
                            .font(.title2)
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        WarningView(text: "fillOutInfo.subtitle".localized(language))
                        Divider()
                            .padding(.top, 20)
                    }
                    .padding(.top, 20)
                    
                    // MARK: - Segmented Control -
                    
                    Picker(selection: $viewModel.gender, label: Spacer()) {
                        ForEach(viewModel.genders) { gender in
                            Text(gender.rawValue.localized(language))
                                .tag(gender)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                    // MARK: - Gender Specific Fill Out View -
                    
                    if viewModel.gender == .male {
                        MaleQazaCalculationView(viewModel: viewModel.maleViewModel)
                    } else {
                        FemaleQazaCalculationView(viewModel: viewModel.femaleViewModel)
                    }
                    
                    // MARK: - Footer -
                    
                    Spacer().frame(width: 0,
                                   height: 44,
                                   alignment: .center)
                    Button(action: {
                        if viewModel.gender == .male {
                            viewModel.maleViewModel.calculateQazaPrayersAmount()
                        } else {
                            viewModel.femaleViewModel.calculateQazaPrayersAmount()
                        }
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
                .padding(EdgeInsets(top: 34, leading: 0, bottom: 0, trailing: 0))
                .keyboardAdaptive()
                .onChange(of: viewModel.gender) { _ in
                    hapticLight()
                }
            }
        }
    }
}

extension QazaCalculationView: Hapticable {}

#Preview {
    QazaCalculationView(viewModel: .init(maleViewModel: .init(completion: {}), femaleViewModel: .init(completion: {})))
}
