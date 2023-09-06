//
//  OnboardingView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 17.08.2023.
//

import SwiftUI

struct OnboardingPageView: View {
    let imageName: String
    let title: String
    
    var body: some View {
        VStack(alignment: .center) {
            Image(imageName)
                .padding(.horizontal, 5)
            Spacer()
            Text(title)
                .font(.largeTitle)
                .bold()
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
                .padding(.top, 20)
            Spacer()
        }
        .padding(.bottom, 40)
        .padding()
    }
}
