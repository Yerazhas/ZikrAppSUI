//
//  PremiumBannerView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 10.10.2023.
//

import SwiftUI

struct PremiumBannerView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    let purchaseAction: () -> Void

    var body: some View {
        ZStack {
            makeLinearGradient(themeFirstColor: "BannerPurpleDark", themeSecondColor: "BannerPurpleLight")
//            Color.purple
                .cornerRadius(10)
            VStack(alignment: .leading) {
                Text("beABetterMuslim".localized(language))
                    .bold()
                    .font(.title3)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                Button {
                    purchaseAction()
                } label: {
                    ZStack {
                        Color.white
                            .cornerRadius(10)
                        Text("claimNow".localized(language))
                            .bold()
                            .foregroundStyle(.black)
                    }
                }
                .frame(height: 50)
            }
            .padding()
        }
    }
}
