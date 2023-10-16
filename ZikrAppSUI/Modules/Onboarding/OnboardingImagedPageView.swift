//
//  OnboardingView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 17.08.2023.
//

import SwiftUI

struct OnboardingImagedPageView: View {
    let imageName: String
    let title: String
    let subtitle: String?
    
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 10) {
                Text(title)
                    .font(.largeTitle)
                    .bold()
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                if let subtitle {
                    Text(subtitle)
                        .bold()
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                }
                Spacer()
                Image(imageName)
                    .aspectRatio(contentMode: .fit)
                    .clipped()
                    .padding(.horizontal, 5)
                    .padding(.bottom, 100)
            }
            .padding(.horizontal, 40)
        }
    }
}
