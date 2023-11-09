//
//  GradientRaysView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 14.10.2023.
//

import SwiftUI

public struct GradientRaysView: View {
    private let initialAngle: CGFloat
    private let colors: [Color]
    private let raysCount: Int
    private let center: UnitPoint

    public init(
        initialAngle: CGFloat = CGFloat.pi / 180,
        raysCount: Int = 17,
        gradientColors: [Color]? = nil,
        center: UnitPoint = .center
    ) {
        self.initialAngle = initialAngle
        self.colors = gradientColors ?? [Color.white, Color.clear]
        self.center = center

        switch center {
        case .bottom, .top, .leading, .trailing:
            self.raysCount = raysCount * 2
        case .topTrailing, .topLeading, .bottomLeading, .bottomTrailing:
            self.raysCount = raysCount * 4
        default:
            self.raysCount = raysCount
        }
    }

    public var body: some View {
        GeometryReader { gr in
            let theta = 2.0 * CGFloat.pi / CGFloat(raysCount * 2)
            let centerPoint = CGPoint(x: gr.size.width * center.x, y: gr.size.height * center.y)
            let radius = max(centerPoint.x, centerPoint.y)

            Path { path in
                path.move(to: centerPoint)

                func point(for angle: CGFloat) -> CGPoint {
                    CGPoint(x: centerPoint.x + radius * cos(angle), y: centerPoint.y + radius * sin(angle))
                }

                var angle = initialAngle
                for _ in 0 ..< raysCount {
                    path.addLine(to: point(for: angle))
                    angle += theta
                    path.addLine(to: point(for: angle))
                    path.addLine(to: centerPoint)
                    angle += theta
                }
            }
            .fill(RadialGradient(colors: colors, center: center, startRadius: 0, endRadius: radius))
            .clipped()
        }
    }

}
