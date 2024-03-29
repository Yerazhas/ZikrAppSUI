//
//  ZikrContentView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 15.01.2023.
//

import SwiftUI

struct ZikrContentView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    let zikr: Zikr
    var body: some View {
        contentView
            .gesture(DragGesture())
    }

    private var contentView: some View {
        GeometryReader { gr in
            ScrollView(.vertical, showsIndicators: false) {
                makeContentView(gr: gr)
            }
        }
    }

    func makeContentView(gr: GeometryProxy) -> some View {
        VStack(spacing: 25) {
            Spacer()
            Text(zikr.arabicTitle)
                .font(.uthmanicArabic(size: 30))
                .fixedSize(horizontal: false, vertical: true)
            Text(zikr.getTranscription(language: language))
                .foregroundColor(.secondary)
            Text(zikr.getTranslation(language: language))
                .foregroundColor(.secondary)
                .italic()
            Spacer()
        }
        .multilineTextAlignment(.center)
        .padding()
        .frame(width: gr.size.width)
        .frame(minHeight: gr.size.height)
        .foregroundColor(.textGray)
    }
}

struct ZikrContentView_Previews: PreviewProvider {
    static var previews: some View {
        ZikrContentView(zikr: .init())
    }
}
