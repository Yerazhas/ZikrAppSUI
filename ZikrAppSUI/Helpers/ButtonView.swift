//
//  ButtonView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 14.10.2023.
//

import SwiftUI

struct ButtonView: View {
    let action: () -> Void
    let text: String
    let backgroundColor: Color
    let foregroundColor: Color

    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                backgroundColor
                    .cornerRadius(8)
                Text(text)
                    .foregroundColor(foregroundColor)
                    .bold()
            }
        }
    }
}
