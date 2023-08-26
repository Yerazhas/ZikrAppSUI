//
//  OffsetKey.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 24.07.2023.
//

import SwiftUI

struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
