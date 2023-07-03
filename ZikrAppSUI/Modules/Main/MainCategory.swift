//
//  MainCategory.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 25.06.2023.
//

import Foundation

struct MainCategory {
    let iconName: String
    let title: String
    let type: ZikrType

    static let availableCategories: [MainCategory] = [
        .init(iconName: "ic-tasbih", title: "zikrs", type: .zikr),
        .init(iconName: "ic-dua", title: "duas", type: .dua),
        .init(iconName: "ic-wird", title: "wirds", type: .wird)
    ]
}
