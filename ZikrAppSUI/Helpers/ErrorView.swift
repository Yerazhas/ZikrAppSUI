//
//  ErrorView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 19.08.2023.
//

import SwiftUI

struct ErrorView: View {
    let closeAction: () -> Void
    let retryAction: () -> Void

    private var errorAnimation: some View {
        LottieView.lottieError(loopMode: .loop)
    }
    private let animationViewSide: CGFloat = 300

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: closeAction) {
                    Image(systemName: "xmark")
                        .renderingMode(.template)
                        .resizable()
                        .foregroundColor(.secondary)
                }
                .frame(width: 18, height: 18)
                Spacer()
            }
            errorAnimation
                .frame(width: animationViewSide, height: animationViewSide)
            Spacer()
            Text("Unable to connect")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            Text("An error occured while loading this page. try again or restart the app")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
            PrimaryButtonView(title: "Try again", action: retryAction)
                .padding(.top, -15)
        }
        .padding()
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView {} retryAction: {}
    }
}
