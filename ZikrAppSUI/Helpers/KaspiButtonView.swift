//
//  KaspiButton.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 12.09.2023.
//

import SwiftUI

public struct KaspiButtonView: View {
    @Environment(\.isEnabled) private var isEnabled
    private var title: String?
    private var isLoading: Bool
    private var action: () -> Void
    @State private var isPressed = false
    
    private var loaderAnimation: some View {
        LottieView.lottieLoader(loopMode: .loop)
    }

    public var body: some View {
        makeBody()
    }

    public init(title: String?, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }

    private func makeBody() -> some View {
        var bgColor: SwiftUI.Color
        if isEnabled {
            bgColor = isPressed ? .kaspiRed : .kaspiRed
        } else {
            bgColor = .kaspiRed.opacity(0.5)
        }

        if isLoading {
            bgColor = .kaspiRed
        }

        let hideShadow = isPressed || !isEnabled || isLoading

        return HStack(spacing: 13) {
            Spacer()
            if isLoading {
                loaderAnimation
                    .frame(width: 24, height: 24)
            }
            if let title = title {
                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .font(.title2)
                    .frame(height: 48)
                    .foregroundColor(Color.white)
            }
            Spacer()
        }
        .frame(height: 52)
        .background(
            bgColor
                .cornerRadius(12)
                .shadow(
                    color: hideShadow ? Color.clear : .kaspiRed,
                    radius: 0,
                    x: 0,
                    y: 4
                )
        )
        .scaleEffect(isPressed ? 0.95 : 1)
        .onTapGesture {
            action()
        }
        .pressAction { isPressed in
            withAnimation(.easeIn(duration: 0.1)) {
                self.isPressed = isPressed
            }
        }
    }
}

