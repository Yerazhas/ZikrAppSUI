//
//  PaywallSuccessView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 19.08.2023.
//

import SwiftUI

struct PaywallSuccessView: View {
    let closeAction: () -> Void

    var body: some View {
        VStack(alignment: .center) {
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
            Image("img-blossom-cherry")
                .frame(width: 250, height: 250)
                .padding(.top, 50)
            Text("Вы успешно подписались на ZikrApp premium, ползуйтесь всеми полезными фичами приложения!")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.top, 50)
            Spacer()
        }
        .padding(.bottom, 40)
        .padding()
    }
}

struct PaywallSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallSuccessView {}
    }
}
