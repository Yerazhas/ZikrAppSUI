//
//  RotatingView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 14.10.2023.
//

import SwiftUI

struct RotatingView<Content>: View where Content: View {
    @State private var raysRotation = Angle(degrees: 0)

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .rotationEffect(raysRotation)
            .onAppear {
                withAnimation(.linear(duration: 40)
                                .repeatForever(autoreverses: false)) {
                    self.raysRotation = Angle(degrees: 360)
                }
            }
    }
}
