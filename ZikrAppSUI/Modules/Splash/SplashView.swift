//
//  SplashView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 14.09.2023.
//

import SwiftUI

struct SplashView: View {
    @StateObject private var viewModel: SplashViewModel

    init(completion: @escaping () -> Void) {
        _viewModel = .init(wrappedValue: .init(completion: completion))
    }

    var body: some View {
        VStack {
            Spacer()
            Image("LaunchScreenLogo")
                .resizable()
                .frame(width: 160, height: 160)
            Spacer()
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView {}
    }
}
