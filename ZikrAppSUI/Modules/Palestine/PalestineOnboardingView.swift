//
//  PalestineOnboardingView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 21.10.2023.
//

import SwiftUI

struct PalestineOnboardingView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    let completion: () -> Void

    var body: some View {
        ZStack {
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .center, spacing: 30) {
                        Text("palestineOnboardingTitle".localized(language))
                            .font(.largeTitle)
                            .multilineTextAlignment(.center)
                        Image("img-flag-palestine")
                        Text("palestineOnboardingSubtitle".localized(language))
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding(.top, 40)
                        Spacer()
                    }
                }
                Button {
                    hapticLight()
                    completion()
                } label: {
                    ZStack {
                        Color.blue
                            .cornerRadius(12)
                        Text("continue".localized(language))
                            .foregroundColor(.white)
                            .bold()
                    }
                }
                .frame(height: 60)
                .padding(.horizontal)
            }
            .padding()
            .padding(.top, 40)
            .interactiveDismissDisabled(true)
        }
    }
}

extension PalestineOnboardingView: Hapticable {}

struct PalestineOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        PalestineOnboardingView {}
    }
}
