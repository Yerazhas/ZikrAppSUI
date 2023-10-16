//
//  PaymentLoaderView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 11.10.2023.
//

import SwiftUI

struct LottieProgressView: View {
    let title: String
    let subtitle: String
    @StateObject private var viewModel: LottieProgressViewModel

    init(title: String, subtitle: String, completion: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self._viewModel = .init(wrappedValue: .init(completion: completion))
    }
    var body: some View {
        ZStack {
            BackgroundBlurView()
                .ignoresSafeArea(.all)
            VStack(alignment: .center, spacing: 0) {
                if Int.random(in: 1...2).isMultiple(of: 2) {
                    LottieView.lottiePaymentLoader(loopMode: .loop)
                        .frame(width: 300, height: 300)
                } else {
                    LottieView.lottiePaymentLoader1(loopMode: .loop)
                        .frame(width: 300, height: 300)
                }
                Text(title)
                    .multilineTextAlignment(.center)
                    .font(.title3)
                Text(subtitle)
                    .font(.callout)
                    .padding(.top, 10)
            }
        }
    }
}

#Preview {
    LottieProgressView(title: "Starting your wonderful journey...", subtitle: "Please don't close the page") {}
}

struct BackgroundBlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
