//
//  LaurelView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 14.10.2023.
//

import SwiftUI

struct LaurelView: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .center) {
            Image("ic-laurel-left")
            VStack {
                Text(title)
                    .font(.system(size: 35))
                    .bold()
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(.system(size: 16))
                    .bold()
                    .multilineTextAlignment(.center)
            }
            Image("ic-laurel-right")
        }
    }
}

//#Preview {
//    LaurelView(title: "Millions", subtitle: "of dhikrs done")
//}
