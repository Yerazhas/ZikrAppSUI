//
//  PaywallView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 13.08.2023.
//

import SwiftUI

struct PaywallView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    @StateObject private var viewModel: PaywallViewModel
    @State private var isPrivacyPolicyPresented: Bool = false
    @State private var isUserAgreementPresented: Bool = false
    @State private var isKaspiPaywallPresented: Bool = false
    @State private var isBeelinePaywallPresented: Bool = false

    @State private var shouldShowError: Bool = false

    init(out: @escaping PaywallViewOut) {
        _viewModel = .init(wrappedValue: .init(out: out))
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
                VStack {
                    ScrollView {
                        VStack(spacing: 0) {
                            HStack {
                                Button(action: viewModel.close) {
                                    Image(systemName: "xmark")
                                        .renderingMode(.template)
                                        .resizable()
                                        .foregroundColor(.secondary)
                                }
                                .allowsHitTesting(!viewModel.isButtonLoading)
                                .frame(width: 18, height: 18)
                                Spacer()
                            }
//                            Image("premium-logo")
//                                .padding(.top, -40)
                            Text("beABetterMuslim".localized(language))
                                .bold()
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .padding(.top, 20)
                            VStack {
                                ForEach(viewModel.benefits, id: \.self) { benefit in
                                    IconTitleView(title: benefit.localized(language))
                                        .padding(.top, 7)
                                }
                            }
                            .padding(.leading, 40)
                            .padding(.top, 20)
                            VStack(spacing: 15) {
                                ForEach(viewModel.products, id: \.product.appStoreId) { product in
                                    ProductButtonView(
                                        product: product,
                                        isSelected: viewModel.selectedProduct == product,
                                        tapAction: { viewModel.selectProduct(product) }
                                    )
                                }
                                .allowsHitTesting(!viewModel.isButtonLoading)
                            }
                            .padding(.top, 40)
                        }
                        .padding()
                        .padding(.bottom, 40)
                    }
                    HStack(spacing: 10) {
                        purchaseButton
                        if viewModel.shouldShowKaspi {
                            KaspiButtonView(
                                title: "pay_with_kaspi".localized(language),
                                isLoading: viewModel.isButtonLoading,
                                action: {
                                    hapticLight()
                                    viewModel.payKaspi()
                                    isKaspiPaywallPresented = true
                                })
                        } else if viewModel.shouldShowBeeline {
                            BeelineButtonView(
                                title: "pay_with_beeline".localized(language),
                                isLoading: viewModel.isButtonLoading,
                                action: {
                                    hapticLight()
                                    isBeelinePaywallPresented = true
                                })
                        }
                    }
                    .padding(.horizontal)
//                    .padding(.top, -15)
                    restorePrivacyButtons
                }
            case .failed:
                ErrorView(closeAction: viewModel.close, retryAction: viewModel.getProducts)
            case .purchaseSuccess:
                PaywallSuccessView(closeAction: viewModel.close)
            }
        }
        .onAppear(perform: viewModel.onAppear)
        .sheet(isPresented: $isPrivacyPolicyPresented) {
            SFSafariView(url: .init(string: "https://docs.google.com/document/d/1k7Pfj9Wr2wAobbGDbXdkeEg5k9nWNMMONA4dyIzgvi0/edit?usp=sharing")!)
        }
        .sheet(isPresented: $isUserAgreementPresented) {
            SFSafariView(url: .init(string: "https://docs.google.com/document/d/16_XCThX2SMjISjyl6XedBaQ9eCasb45swItT_1DbJDA/edit?usp=sharing")!)
        }
        .sheet(isPresented: $isKaspiPaywallPresented) {
            KaspiPaywallView(products: viewModel.products)
        }
        .sheet(isPresented: $isBeelinePaywallPresented) {
            KaspiPaywallView(isKaspi: false, products: viewModel.products)
        }
        .fullScreenCover(isPresented: $viewModel.shouldShowLoader, onDismiss: {
            guard viewModel.error != nil else { return }
            shouldShowError = true
        }, content: {
            LottieProgressView(title: "purchaseProgressTitle".localized(language), subtitle: "dontClosePage".localized(language))
        })
        .alert(isPresented: $shouldShowError) {
            Alert(
                title: Text("subscriptionFailed".localized(language)),
                message: Text("tryAgain".localized(language)),
                primaryButton: .default(Text("retry".localized(language))) {
                    viewModel.purchase()
                },
                secondaryButton: .cancel({
                    viewModel.shouldShowLoader = false
                })
            )
        }
    }

    private var restorePrivacyButtons: some View {
        HStack(spacing: 20) {
            Button("restore".localized(language)) {
                viewModel.restorePurchases()
            }
            Button("termsOfUse".localized(language)) {
                isUserAgreementPresented = true
            }
            Button("privacyPolicy".localized(language)) {
                isPrivacyPolicyPresented = true
            }
        }
        .allowsHitTesting(!viewModel.isButtonLoading)
        .foregroundColor(.secondary)
        .font(.caption)
        .frame(height: 40)
    }

    private var purchaseButton: some View {
        PrimaryButtonView(
            title: "continue".localized(language),
            isLoading: viewModel.isButtonLoading,
            action: {
                viewModel.purchase()
            })
        .allowsHitTesting(!viewModel.isButtonLoading)
//        .padding(.horizontal)
    }
}

extension PaywallView: Hapticable {}

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView { _ in }
    }
}
