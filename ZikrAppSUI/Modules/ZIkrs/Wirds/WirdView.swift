//
//  WirdView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 17.01.2023.
//

import SwiftUI

struct WirdView: View {
    @AppStorage("shouldHideZikrAmount") private var shouldHideZikrAmount: Bool = false
    @AppStorage("language") private var language = LocalizationService.shared.language
    @AppStorage("themeFirstColor") private var themeFirstColor = ThemeService.shared.firstColor
    @AppStorage("themeSecondColor") private var themeSecondColor: String?
    let wird: Wird

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .cornerRadius(10)
                .shadow(color: Color(.lightGray).opacity(0.1), radius: 14)
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(wird.type.rawValue.localized(language))
                            .font(.headline)
                            .foregroundLinearGradient(themeFirstColor: themeFirstColor, themeSecondColor: themeSecondColor)
                        Spacer()
                    }
                    .padding(.bottom, 7)
                    Group {
                        Text(wird.title.localized(language))
                        Text(wird.getSubtitle(language: language))
                            .foregroundColor(.secondary)
                            .font(.footnote)
                        if let repeatTimes = wird.repeatTimes {
                            Text(
                                "repeat".localized(language, args: String(repeatTimes))
                            )
                            .foregroundLinearGradient(themeFirstColor: themeFirstColor, themeSecondColor: themeSecondColor)
                            .padding(.top, 7)
                            .font(.subheadline)
                        }
                    }
                    .multilineTextAlignment(.leading)
                    Spacer()
                }

                if !shouldHideZikrAmount {
                    Text("\(wird.totalDoneCount)")
                        .font(.system(size: 40))
                        .foregroundLinearGradient(themeFirstColor: themeFirstColor, themeSecondColor: themeSecondColor)
                        .minimumScaleFactor(0.5)
                        .padding()
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
        }
    }
}

struct WirdView_Previews: PreviewProvider {
    static var previews: some View {
        WirdView(wird: .init())
    }
}

