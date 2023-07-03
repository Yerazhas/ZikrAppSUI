//
//  MainCategoryView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 25.06.2023.
//

import SwiftUI

struct MainCategoryView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    let category: MainCategory

    var body: some View {
        ZStack {
            Color(.systemBackground)
            VStack(spacing: 5) {
                ZStack {
                    if let firstChar = category.title.localized(language).first, let firstCharStr = String(firstChar) {
                        Text(firstCharStr)
                            .font(.largeTitle)
                            .multilineTextAlignment(.center)
//                            .foregroundColor(.secondary)
                    }
                }
//                .frame(width: 50, height: 50)
                Text(category.title.localized(language))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct MainCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        MainCategoryView(category: .init(iconName: "ic-quran", title: "Salah", type: .zikr))
    }
}
