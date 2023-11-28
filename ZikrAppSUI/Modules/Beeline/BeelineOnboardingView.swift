//
//  BeelineOnboardingView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 27.11.2023.
//

import SwiftUI

struct BeelineOnboardingView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    let completion: () -> Void

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea(.all)
            VStack {
                ScrollView {
                    VStack(alignment: .center, spacing: 20) {
                        HStack {
                            Spacer()
                            Image("img-beeline-logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 30)
                            Spacer()
                        }
                        Text("Теперь оплата ZikrApp Premium возможна из России через Билайн.")
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                }
                Button {
                        hapticLight()
                        completion()
                } label: {
                    ZStack {
                        Color.beelineYellow
                            .cornerRadius(12)
                        Text("continue".localized(language))
                            .foregroundColor(.black)
                            .bold()
                    }
                }
                .frame(height: 60)
                .padding(.horizontal)
            }
            .padding()
            .padding(.top, 60)
        }
    }
}

extension BeelineOnboardingView: Hapticable {}

struct BeelineOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        BeelineOnboardingView {}
    }
}
