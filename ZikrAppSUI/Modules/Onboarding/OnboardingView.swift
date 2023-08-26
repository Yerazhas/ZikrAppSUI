//
//  OnboardingView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 17.08.2023.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage: Int = 0
    @AppStorage("language") private var language = LocalizationService.shared.language
    let completion: () -> Void

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            VStack {
                HStack {
                    Spacer()
                    Button("skip".localized(language)) {
                        completion()
                    }
                    .foregroundColor(.blue)
                }
                TabView(selection: $currentPage) {
                    OnboardingPageView(
                        imageName: "img-serene-sunset",
                        title: "onboarding_title_1".localized(language)
                    )
                    .tag(0)
                    OnboardingPageView(
                        imageName: "img-prayer",
                        title: "onboarding_title_2".localized(language)
                    )
                    .tag(1)
                    OnboardingPageView(
                        imageName: "img-blossom-cherry",
                        title: "onboarding_title_3".localized(language)
                    )
                    .tag(2)
                }
                .animation(.default)
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                Button {
                    if currentPage < 2 {
                        currentPage += 1
                    } else {
                        completion()
                    }
                } label: {
                    ZStack {
                        Color.blue
                            .cornerRadius(8)
                        Text("continue".localized(language))
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                }
                .frame(height: 60)
                .padding(.bottom, 20)
                .padding(.horizontal)
            }
            .padding(.horizontal)
            .padding(.top, 5)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView {}
    }
}
