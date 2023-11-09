//
//  SupportPaywallView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 18.08.2023.
//

import SwiftUI
import Factory

struct SupportPaywallView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    @StateObject private var viewModel: SupportPaywallViewModel
    @Injected(Container.appStatsService) private var appStatsService
    @State private var isKaspiEnabled: Bool = false
    
    init(completion: @escaping () -> Void) {
        _viewModel = .init(wrappedValue: .init(completion: completion))
        _isKaspiEnabled = .init(wrappedValue: appStatsService.showsRI && [Language.ru, .kz].contains(language))
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
            case .loaded:
                VStack(spacing: 25) {
                    ScrollView(showsIndicators: false) {
                        VStack {
                            Text("mission".localized(language))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 40)
                            VStack(spacing: 15) {
                                ForEach(viewModel.products, id: \.product.skProduct?.productIdentifier) { product in
                                    SupportProductButtonView(
                                        product: product,
                                        isSelected: viewModel.selectedProduct == product,
                                        tapAction: { viewModel.selectProduct(product) }
                                    )
                                }
                                .allowsHitTesting(!viewModel.isButtonLoading)
                            }
                            if isKaspiEnabled {
                                Text("kaspi_donate".localized(language))
                                    .bold()
                                    .padding(.top, 30)
                                kaspiView
                                Text("copy_requisites".localized(language))
                                    .bold()
                                    .foregroundColor(.systemGreen)
                            }
                            Spacer()
                                .padding(.bottom, 40)
                        }
                    }
                    purchaseButton
                        .allowsHitTesting(!viewModel.isButtonLoading)
                        .padding(.top, -15)
                }
                .padding()
            case .failed(let error):
                Text(error.localizedDescription)
            }
        }
        .onAppear(perform: viewModel.onAppear)
        
    }

    private var purchaseButton: some View {
        ZStack {
            let gradientColor = Color.paleGray
            PrimaryButtonView(
                title: "donate".localized(language),
                isLoading: viewModel.isButtonLoading,
                action: {
                viewModel.purchase()
            })
            .allowsHitTesting(!viewModel.isButtonLoading)
            .padding(.horizontal)
            .padding(.bottom)
        }
    }

    private var kaspiView: some View {
        ZStack {
            Image("img_kaspi_gold")
                .resizable()
                .cornerRadius(10)
                .shadow(radius: 3, y: 3)
                .frame(height: 200)
            let phone = "+7 747 352 83 57"
            let card = "4400 4301 6275 1215"
            VStack(alignment: .leading, spacing: 40) {
                Text("Ерасыл Ж.")
                Button(phone) {
                    hapticLight()
                    UIPasteboard.general.string = phone
                }
                Button(card) {
                    hapticLight()
                    UIPasteboard.general.string = card
                }
            }
            .padding(.leading, -100)
            .font(.title2)
            .foregroundColor(.white)
        }
    }
}

extension SupportPaywallView: Hapticable {}

struct SupportPaywallView_Previews: PreviewProvider {
    static var previews: some View {
        SupportPaywallView {}
    }
}
