//
//  ZikrView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 15.01.2023.
//

import SwiftUI

struct ZikrView: View {
    let zikr: Zikr
    @AppStorage("language") private var language = LocalizationService.shared.language

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .cornerRadius(10)
                .shadow(color: Color(.lightGray).opacity(0.1), radius: 14)
            VStack(alignment: .center, spacing: 5) {
                HStack {
                    Text(zikr.type.rawValue.localized(language))
                        .font(.headline)
                        .foregroundColor(.systemGreen)
                    Spacer()
                    Image("ic-checkmark")
                        .opacity(0)
                }
                Spacer()
                Group {
                    Text(zikr.title.localized(language))
                    Text(zikr.getTranscription(language: language))
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
                .multilineTextAlignment(.center)
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
        }
    }
}

struct ZikrView_Previews: PreviewProvider {
    static var previews: some View {
        ZikrView(zikr: Zikr())
    }
}
