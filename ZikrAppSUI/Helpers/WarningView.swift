//
//  WarningView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 08.10.2023.
//

import SwiftUI

struct WarningView: View {
    let text: String

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.gray)
            Text(text)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
    }
}

//#Preview {
//    WarningView(text: "Random text!")
//}
