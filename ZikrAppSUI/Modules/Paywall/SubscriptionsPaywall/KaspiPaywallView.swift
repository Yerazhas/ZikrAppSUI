//
//  KaspiPaywallView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 12.09.2023.
//

import SwiftUI
import Factory

struct KaspiPaywallView: View {
    private let products: [PaywallProduct]
    private var selectedProduct: PaywallProduct?
    @AppStorage("language") private var language = LocalizationService.shared.language
    @Injected(Container.appStatsService) private var appStatsService
    @Injected(Container.analyticsService) private var analyticsService

    init(products: [PaywallProduct]) {
        self.products = products
        selectedProduct = self.products.dropLast().last
    }

    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(products, id: \.product.appStoreId) { product in
                        ProductButtonView(
                            product: product,
                            isSelected: selectedProduct == product,
                            isFullyDisplayed: false,
                            tapAction: {}
                        )
                    }
                    .allowsHitTesting(false)
                    Text("send_money_to_kaspi".localized(language))
                        .bold()
                        .padding(.top, 40)
                    kaspiView
                    Text("copy_requisites".localized(language))
                        .bold()
                        .foregroundColor(.systemGreen)
                    Text("send_check_to_whatsapp".localized(language))
                        .bold()
                    Spacer()
                        .padding(.bottom, 40)
                }
                .padding()
            }
            PrimaryButtonView(
                title: "send_check".localized(language),
                isLoading: false,
                action: {
                    hapticLight()
                    analyticsService.trackSendCheck()
                    guard let url = URL(string: "https://api.whatsapp.com/send?phone=77473528357&text=\("ios_msg".localized(language, args: String(appStatsService.qonversionId)))".encodeUrl) else { return }
                    UIApplication.shared.open(url)
                })
            .padding(.horizontal)
            .padding(.top, -15)
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

extension KaspiPaywallView: Hapticable {}

struct KaspiPaywallView_Previews: PreviewProvider {
    static var previews: some View {
        KaspiPaywallView(products: [])
    }
}
