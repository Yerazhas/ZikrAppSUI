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
                .frame(width: 250, height: 250)
                .padding(.top, 50)
            Text(title)
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.top, 50)
            Spacer()
        }
        .padding(.bottom, 40)
        .padding()
    }
}
