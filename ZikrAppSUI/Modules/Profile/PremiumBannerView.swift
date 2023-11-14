//
//  PremiumBannerView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 10.10.2023.
//

import SwiftUI
import Factory

struct PremiumBannerView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    @Injected(Container.appStatsService) private var appStatsService
    let purchaseAction: () -> Void

    var body: some View {
        ZStack {
            makeLinearGradient(themeFirstColor: "BannerPurpleDark", themeSecondColor: "BannerPurpleLight")
//            Color.purple
                .cornerRadius(10)
            VStack(alignment: .leading) {
                Group {
                    if appStatsService.offering.contains("banner") {
                        Text("beABetterMuslim1".localized(language))
                            .bold()
                    } else {
                        Text("beABetterMuslim".localized(language))
                            .bold()
                    }
                }
                    .font(.title3)
//                    .foregroundStyle(.white)
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
