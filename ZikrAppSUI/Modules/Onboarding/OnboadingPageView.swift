//
//  OnboadingPageView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 16.10.2023.
//

import SwiftUI

struct OnboardingPageView<Content: View>: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    let title: String
    let subtitle: String?
    @ViewBuilder let content: Content
    
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 10) {
                Text(title.localized(language))
                    .font(.largeTitle)
                    .bold()
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                if let subtitle {
                    Text(subtitle.localized(language))
                        .bold()
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                }
                Spacer()
                content
            }
            .padding(.horizontal, 10)
        }
    }
}
