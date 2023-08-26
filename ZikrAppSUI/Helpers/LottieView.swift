//
//  LottieView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 15.08.2023.
//

import SwiftUI
import Lottie

public struct ZikrAppLottie {
    let animationName: String
    let bundle: Bundle

    public init(animationName: String, bundle: Bundle) {
        self.animationName = animationName
        self.bundle = bundle
    }
}

public struct LottieView: UIViewRepresentable {
    private let animationName: String
    private let bundle: Bundle
    private let loopMode: LottieLoopMode
    private let showOnlyLastFrame: Bool

    public init(
        lottie: ZikrAppLottie,
        loopMode: LottieLoopMode = .playOnce,
        showOnlyLastFrame: Bool = false
    ) {
        self.animationName = lottie.animationName
        self.loopMode = loopMode
        self.bundle = lottie.bundle
        self.showOnlyLastFrame = showOnlyLastFrame
    }

    public func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)

        let animationView = LottieAnimationView(
            animation: LottieAnimation.named(animationName, bundle: bundle),
            imageProvider: BundleImageProvider(bundle: bundle, searchPath: nil)
        )
        let animation = LottieAnimation.named(animationName, bundle: bundle)
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = loopMode
        animationView.play(fromProgress: showOnlyLastFrame ? 1: 0, toProgress: 1)

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {}
}


extension LottieView {
    static func lottieLoader(loopMode: LottieLoopMode = .playOnce, showOnlyLastFrame: Bool = false) -> LottieView {
      createView(name: "lottie-loader", loopMode: loopMode, showOnlyLastFrame: showOnlyLastFrame)
    }

    static func lottieError(loopMode: LottieLoopMode = .playOnce, showOnlyLastFrame: Bool = false) -> LottieView {
        createView(name: "lottie-error", loopMode: loopMode, showOnlyLastFrame: showOnlyLastFrame)
    }

    static func createView(name: String, loopMode: LottieLoopMode, showOnlyLastFrame: Bool) -> LottieView {
      return LottieView(lottie: .init(animationName: name, bundle: BundleToken().bundle), loopMode: loopMode, showOnlyLastFrame: showOnlyLastFrame)
    }

    private final class BundleToken {
      let bundle: Bundle = {
        Bundle(for: BundleToken.self)
      }()
    }
}
