//
//  SupportPaywallView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 18.08.2023.
//

import SwiftUI

struct SupportPaywallView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    @StateObject private var viewModel: SupportPaywallViewModel
    
    init(completion: @escaping () -> Void) {
        _viewModel = .init(wrappedValue: .init(completion: completion))
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
                    Text("mission".localized(language))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
//                        .font(.title2)/
                        .padding(.top, 40)
                    VStack(spacing: 15) {
                        ForEach(viewModel.products, id: \.skProduct?.productIdentifier) { product in
                            SupportProductButtonView(
                                product: product,
                                isSelected: viewModel.selectedProduct == product,
                                tapAction: { viewModel.selectProduct(product) }
                            )
                        }
                        .allowsHitTesting(!viewModel.isButtonLoading)
                    }
                    Spacer()
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
}

struct SupportPaywallView_Previews: PreviewProvider {
    static var previews: some View {
        SupportPaywallView {}
    }
}
