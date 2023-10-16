//
//  BeforeAndAfterView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 16.10.2023.
//

import SwiftUI

struct BeforeAndAfterView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language

    var body: some View {
        ZStack {
            Color(.secondarySystemBackground)
                .ignoresSafeArea(.all)
            HStack(spacing: 0) {
                BeforeView(
                    backgroundColor: .init(hex: "BDBDBD"),
                    icon: .init("ic-storm"),
                    title: "before".localized(language),
                    textIcon: .init(systemName: "xmark.app.fill"),
                    texts: [
                        "beforeText1".localized(language),
                        "beforeText2".localized(language),
                        "beforeText3".localized(language),
                        "beforeText4".localized(language)
                    ])
                    .foregroundColor(.white)
                    .frame(height: 400)
                Image(systemName: "arrowshape.turn.up.right.fill")
                    .resizable()
                    .frame(width: 20, height: 15)
                    .rotationEffect(.degrees(-20))
                    .padding(.leading, -10)
                    .padding(.trailing, -10)
                    .foregroundColor(.textGray)
                    .zIndex(1)
                BeforeView(
                    backgroundColor: .systemGreen,
                    icon: .init("ic-sun"),
                    title: "after".localized(language),
                    textIcon: .init(systemName: "checkmark.square.fill"),
                    texts: [
                        "afterText1".localized(language),
                        "afterText2".localized(language),
                        "afterText3".localized(language),
                        "afterText4".localized(language)
                    ]
                )
                    .frame(height: 400)
                    .foregroundColor(.white)
                    .padding(.top, -50)
            }
        }
    }
}

#Preview {
    BeforeAndAfterView()
}
