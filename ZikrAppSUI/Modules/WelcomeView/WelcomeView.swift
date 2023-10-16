//
//  WelcomeView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 14.10.2023.
//

import SwiftUI

struct WelcomePagePromo {
    let title: String
    let subtitle: String
}

struct WelcomeView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    let completion: () -> Void
    let promos: [WelcomePagePromo] = [
        .init(title: "welcomePromoTitle1", subtitle: "welcomePromoSubtitle1"),
        .init(title: "welcomePromoTitle2", subtitle: "welcomePromoSubtitle2"),
        .init(title: "welcomePromoTitle3", subtitle: "welcomePromoSubtitle3")
    ]

    var body: some View {
        ZStack {
//            Color(hex: 0xA3E4BE)
            Color.yellow
                .ignoresSafeArea(.all)
                .ignoresSafeArea(.all)
            RotatingView {
                GradientRaysView(gradientColors: [Color(hex: 0xFFFFFF, alpha: 0.7), Color.clear], center: .center)
                    .frame(width: 100, height: 100)
                    .scaleEffect(x: 10, y: 10, anchor: .center)
            }
            VStack(spacing: 35) {
                Spacer()
                ForEach(promos, id: \.title) {
                    promo in
                    LaurelView(
                        title: promo.title.localized(language),
                        subtitle: promo.subtitle.localized(language)
                    )
                    .foregroundColor(.black)
                }
                Spacer()
                RoundedRectangle(cornerSize: CGSize(width: 20, height: 10))
                    .fill(Color.white)
                    .edgesIgnoringSafeArea(.bottom)
                    .frame(maxHeight: 220)
                    .overlay {
                        VStack(spacing: 15) {
                            Text("welcomeTitle".localized(language))
                                .font(.largeTitle)
                                .bold()
                            Text("welcomeSubtitle".localized(language))
                                .font(.title3)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                            ButtonView(
                                action: {
                                hapticLight()
                                completion()
                            },
                                text: "continue".localized(language), backgroundColor: .black, foregroundColor: .white
                            )
                            .frame(height: 60)
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                        .foregroundColor(.black)
                        .padding(.top, 20)
                        .padding(.horizontal)
                    }
            }
        }
    }
}

extension WelcomeView: Hapticable {}

#Preview {
    WelcomeView {}
}
