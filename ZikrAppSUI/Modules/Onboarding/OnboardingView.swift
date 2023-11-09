//
//  OnboardingView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 17.08.2023.
//

import SwiftUI

struct OnboardingPageData {
    let imageName: String
    let titleKey: String
    let subtitleKey: String?
}

struct OnboardingView: View {
    let pagesData: [OnboardingPageData]
    @State private var currentPage: Int = 0
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("language") private var language = LocalizationService.shared.language
    let completion: () -> Void

    var body: some View {
        ZStack {
            Color.paleGray
                .ignoresSafeArea()
            ZStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<pagesData.count, id: \.self) { index in
                        OnboardingImagedPageView(imageName: pagesData[index].imageName, title: pagesData[index].titleKey.localized(language), subtitle: pagesData[index].subtitleKey?.localized(language))
                            .tag(index)
                    }
                    OnboardingPageView(title: "onboarding_title_4", subtitle: nil) {
                        BeforeAndAfterView()
                    }
                    .tag(pagesData.count)
                }
                .animation(.default)
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                VStack {
                    Spacer()
                    ZStack {
                        Color.paleGray
                            .blur(radius: 20)
                            .frame(maxHeight: 150)
                            .padding(.top, -30)
                        ButtonView(
                            action: {
                                hapticLight()
                                if currentPage < pagesData.count + 1 - 1 && pagesData.count + 1 > 1 { // + 1 is for additional page in the end
                                    currentPage += 1
                                } else {
                                    completion()
                                }
                            },
                            text: "continue".localized(language),
                            backgroundColor: .primary,
                            foregroundColor: colorScheme == .light ? .white : .black
                        )
                        .frame(height: 60)
                        .padding(.bottom, 20)
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.top, 5)
        }
    }
}

extension OnboardingView: Hapticable {}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(pagesData: []) {}
    }
}
