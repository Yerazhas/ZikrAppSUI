//
//  BlurredView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 25.06.2023.
//

import SwiftUI

struct BlurredView: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: 5)
            Text("Premium feature")
        }
    }
}

extension View {
    func premium() -> some View {
        modifier(BlurredView())
    }
}
