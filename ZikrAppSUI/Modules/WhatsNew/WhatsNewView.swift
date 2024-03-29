//
//  WhatsNewView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 17.08.2023.
//

import SwiftUI
import Factory

struct WhatsNewView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    private var benefits: [String] = []

    @Injected(Container.appStatsService) private var appStatsService
    let completion: () -> Void

    init(completion: @escaping () -> Void) {
        self.completion = completion
        if [Language.ru, .kz].contains(language) && appStatsService.showsRI {
            benefits = [
                "whatsnewBenefitsTitle",
                "whatsnewBenefits7",
                "whatsnewBenefits1",
                "whatsnewBenefits2",
                "whatsnewBenefits3",
                "whatsnewBenefits4"
            ]
        } else {
            benefits = [
                "whatsnewBenefitsTitle",
                "whatsnewBenefits1",
                "whatsnewBenefits2",
                "whatsnewBenefits3",
                "whatsnewBenefits4"
            ]
        }
    }

    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    Text("whatsNew".localized(language))
                        .font(.largeTitle)
                        .bold()
                        .fixedSize(horizontal: false, vertical: true)
                    ForEach(benefits, id: \.self) { benefit in
                        IconTitleView(title: benefit.localized(language))
                            .padding(.top, 7)
                    }
                    .padding(.leading, 40)
                    .padding(.top, 20)
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

struct WhatsNewView_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewView {}
    }
}

extension WhatsNewView: Hapticable {}
