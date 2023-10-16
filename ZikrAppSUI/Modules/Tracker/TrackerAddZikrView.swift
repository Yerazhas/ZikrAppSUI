//
//  TrackerAddZikrView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 14.09.2023.
//

import SwiftUI

struct TrackerAddZikrView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    @AppStorage("themeFirstColor") private var themeFirstColor = ThemeService.shared.firstColor
    @AppStorage("themeSecondColor") private var themeSecondColor: String?
    let zikr: Zikr

    var body: some View {
        GeometryReader { gr in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: gr.size.width)
                HStack {
                    Text(zikr.title.localized(language))
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.5)
                        .foregroundColor(.primary)
                        .padding(.leading)
                    Spacer()
                }
                .padding(.vertical)
            }
            .cornerRadius(10)
        }
    }
}
