//
//  ZikrShareView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 15.07.2023.
//

import SwiftUI

struct ZikrShareView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    @AppStorage("themeFirstColor") private var themeFirstColor = ThemeService.shared.firstColor
    @AppStorage("themeSecondColor") private var themeSecondColor: String?
    let zikr: Zikr
    let gr: GeometryProxy

    var body: some View {
        ZStack {
            Color.paleGray
                .ignoresSafeArea()
            VStack(alignment: .center, spacing: 20) {
                ZikrContentView(zikr: zikr)
                    .makeContentView(gr: gr)
                Image(uiImage: Bundle.main.icon ?? UIImage())
                    .resizable()
                    .cornerRadius(10)
                    .frame(width: 60, height: 60)
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
}

//struct ZikrShareView_Previews: PreviewProvider {
//    static var previews: some View {
//        GeometryReader { gr in
//            ZikrShareView(zikr: .init(), gr: gr)
//        }
//    }
//}

extension Bundle {
    public var icon: UIImage? {
        if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
            let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
            let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
            let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
}
