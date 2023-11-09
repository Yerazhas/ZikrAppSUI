//
//  ThemeView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 11.07.2023.
//

import SwiftUI
import Factory

struct ThemeView: View {
    @Injected(Container.themeService) private var themeService
    @Injected(Container.subscriptionSyncService) private var subscriptionService
    @AppStorage("themeFirstColor") private var themeFirstColor = ThemeService.shared.firstColor
    @AppStorage("themeSecondColor") private var themeSecondColor: String?
    let out: () -> Void
    private let rows = [
        GridItem(.flexible(maximum: 100)),
        GridItem(.flexible(maximum: 100))
    ]
    
    var body: some View {
        GeometryReader { gr in
            VStack {
                LazyHGrid(rows: rows, spacing: 10) {
                    ForEach(themeService.themes) { theme in
                        let isCurrentTheme = theme.id == "\(themeFirstColor)\(themeSecondColor ?? "")"
                        makeLinearGradient(themeFirstColor: theme.firstColor, themeSecondColor: theme.secondColor)
                            .frame(width: (gr.size.width - 60) / 5, height: (gr.size.width - 60) / 5)
                            .cornerRadius(10)
                            .overlay(
                                Image(systemName: isCurrentTheme ? "checkmark" : "")
                                    .renderingMode(.template)
                                    .foregroundColor(Color(.systemBackground))
                            )
                            .padding(.vertical)
                            .onTapGesture {
                                if subscriptionService.isSubscribed {
                                    hapticLight()
                                    themeService.setThemeColor(to: theme)
                                } else {
                                    hapticStrong()
                                    out()
                                }
                            }
                    }
                }
                .frame(height: 250) 
                .padding(.leading, 10)
//                Spacer()
            }
        }
        .navigationBarHidden(false)
    }
}

extension ThemeView: Hapticable {}

struct ThemeView_Previews: PreviewProvider {
    static var previews: some View {
        ThemeView {}
    }
}
