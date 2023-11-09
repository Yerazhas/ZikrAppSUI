//
//  WirdShareView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 18.07.2023.
//

import SwiftUI

struct WirdShareView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    @AppStorage("themeFirstColor") private var themeFirstColor = ThemeService.shared.firstColor
    @AppStorage("themeSecondColor") private var themeSecondColor: String?
    @StateObject private var viewModel: WirdShareViewModel
    let gr: GeometryProxy

    init(wird: Wird, gr: GeometryProxy) {
        _viewModel = StateObject(wrappedValue: .init(wird: wird))
        self.gr = gr
    }

    var body: some View {
        ZStack {
            Color.paleGray
                .ignoresSafeArea()
            VStack(alignment: .center, spacing: 20) {
                Text(viewModel.wird.title.localized(language))
                    .font(.title)
                    .bold()
                    .foregroundColor(.secondary)
                    .padding(.bottom, -20)
                    .padding(.top, 10)
                    .multilineTextAlignment(.center)
                    .frame(width: gr.size.width)
                ForEach(Array(viewModel.targetedZikrs.enumerated()), id: \.1) { index, targetedZikr in
                    makeContentView(zikr: targetedZikr.zikr, targetCount: viewModel.wird.zikrs[index].targetCount)
                        .padding(.bottom, -20)
                }
                Image(uiImage: Bundle.main.icon ?? UIImage())
                    .resizable()
                    .cornerRadius(10)
                    .frame(width: 60, height: 60)
                    .padding(.top, 20)
                Text("zikr app")
                    .font(.title)
                    .foregroundColor(.secondary)
                    .padding(.top, -15)
                Text("https://apps.apple.com/app/zikrapp-dhikr-dua-tasbih/id1590270292")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .padding(.bottom, 20)
        }
    }

    @ViewBuilder private func makeContentView(zikr: Zikr, targetCount: Int) -> some View {
        VStack(spacing: 25) {
            Spacer()
            Text(zikr.arabicTitle)
                .font(.uthmanicArabic(size: 30))
                .fixedSize(horizontal: false, vertical: true)
            Text(zikr.getTranscription(language: language))
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(.secondary)
            Text(zikr.getTranslation(language: language))
                .italic()
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(.secondary)
            Text("repeat".localized(language, args: "\(targetCount)"))
                .foregroundColor(.systemGreen)
            Spacer()
        }
        .multilineTextAlignment(.center)
        .padding()
        .frame(width: gr.size.width)
        .foregroundColor(.textGray)
    }
}

//struct WirdShareView_Previews: PreviewProvider {
//    static var previews: some View {
//        WirdShareView()
//    }
//}
