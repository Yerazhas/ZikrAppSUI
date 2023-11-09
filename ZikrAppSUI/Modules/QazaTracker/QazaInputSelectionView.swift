//
//  QazaInputSelectionView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 08.10.2023.
//

import SwiftUI
import Factory

struct QazaInputSelectionView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    @Environment(\.colorScheme) private var colorScheme
    @State private var isCalculationViewPresented: Bool = false
    @State private var isManualEnterViewPresented: Bool = false
    @State private var shouldShowLoader: Bool = false
    @State private var closeSheetWithAlert = false
    @Injected(Container.appStatsService) private var appStatsService

    var body: some View {
        makeBody()
            .fullScreenCover(isPresented: $shouldShowLoader) {
                LottieProgressView(
                    title: "calculationProgressTitle".localized(language),
                    subtitle: "dontClosePage".localized(language),
                    completion: {
                        appStatsService.didSetUpQazaPage()
                    }
                )
            }
            .sheet(isPresented: $isManualEnterViewPresented, onDismiss: {
                shouldShowLoader = closeSheetWithAlert
            }) {
                QazaManualInputView {
                    closeSheetWithAlert = true
                    isManualEnterViewPresented = false
                }
            }
            .sheet(isPresented: $isCalculationViewPresented, onDismiss: {
                shouldShowLoader = closeSheetWithAlert
            }) {
                QazaCalculationView(viewModel: .init(maleViewModel: .init(completion: {
                    closeSheetWithAlert = true
                    isCalculationViewPresented = false
                }), femaleViewModel: .init(completion: {
                    closeSheetWithAlert = true
                    isCalculationViewPresented = false
                })))
            }
    }

    @ViewBuilder
    private func makeBody() -> some View {
        GeometryReader { gr in
            ZStack {
                VStack {
                    Spacer()
                    Image("img-mosque")
                        .renderingMode(.template)
                        .foregroundColor(.secondary)
                        .frame(width: gr.size.width)
                }
                VStack(alignment: .center, spacing: 20) {
                    Spacer()
                    Text("qazaCalculationIntroText".localized(language))
                        .font(.title3)
                        .bold()
                        .multilineTextAlignment(.center)
                    Group {
                        Button {
                            hapticLight()
                            isManualEnterViewPresented = true
                        } label: {
                            ZStack {
//                                Color(hex: "#A6C053")
                                Color.systemGreen
//                                    .opacity(0.5)
                                    .cornerRadius(10)
                                Text("knowQazaAmount".localized(language))
                                    .bold()
                                    .foregroundColor(colorScheme == .light ? .white : .black)
                            }
                            .frame(height: 50)
                            .padding(.horizontal)
                        }
                        .padding(.top, 40)

                        Button {
                            hapticLight()
                            isCalculationViewPresented = true
                        } label: {
                            ZStack {
//                                Color(hex: "#A6C053")
                                Color.systemGreen
//                                    .opacity(0.5)
                                    .cornerRadius(10)
                                Text("dontKnowQazaAmount".localized(language))
                                    .bold()
                                    .foregroundColor(colorScheme == .light ? .white : .black)
                            }
                            .frame(height: 50)
                            .padding(.horizontal)
                        }
                        WarningView(text: "hanafiCalculation".localized(language))
                            .padding(.top, -15)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding()
            }
        }
    }
}

extension QazaInputSelectionView: Hapticable {}

//#Preview {
//    QazaInputSelectionView()
//}
