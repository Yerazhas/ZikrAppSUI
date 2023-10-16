//
//  ThemeService.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 11.07.2023.
//

import Foundation
import Factory

final class ThemeService {
    static let shared = ThemeService()

    private init() {}

    var firstColor: String {
        UserDefaults.standard.string(forKey: .themeFirstColor) ?? "SystemGreen"
    }

    let themes: [ThemeColor] = [
        .init(firstColor: "SystemGreen", secondColor: nil),
        .init(firstColor: "SystemGreen", secondColor: "ThemeBlue"),
        .init(firstColor: "ThemeYellow", secondColor: "ThemeOrange"),
        .init(firstColor: "ThemeDarkGreen", secondColor: nil),
        .init(firstColor: "ThemeYellow1", secondColor: nil),
        .init(firstColor: "ThemeBlue1", secondColor: "ThemePurple"),
        .init(firstColor: "ThemeRed", secondColor: nil),
        .init(firstColor: "ThemeBlue1", secondColor: nil),
        .init(firstColor: "ThemeBrown", secondColor: nil),
        .init(firstColor: "ThemePurple1", secondColor: nil)
    ]

    func setThemeColor(to color: ThemeColor) {
        setFirstColor(to: color.firstColor)
        setSecondColor(to: color.secondColor)
    }

    func setFirstColor(to colorName: String) {
        UserDefaults.standard.set(colorName, forKey: .themeFirstColor)
    }

    func setSecondColor(to colorName: String?) {
        UserDefaults.standard.set(colorName, forKey: .themeSecondColor)
    }

    func setDefaultTheme() {
        setThemeColor(to: themes[0])
    }
}

struct ThemeColor: Identifiable {
    let firstColor: String
    let secondColor: String?

    var id: String {
        "\(firstColor)\(secondColor ?? "")"
    }
}

extension String {
    static let themeFirstColor = "themeFirstColor"
    static let themeSecondColor = "themeSecondColor"
}


extension Container {
    static let themeService = Factory<ThemeService> {
        ThemeService.shared
    }
}
