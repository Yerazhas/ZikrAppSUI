//
//  BeforeView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 16.10.2023.
//

import SwiftUI

struct BeforeView: View {
    let backgroundColor: Color
    let icon: Image
    let title: String
    let textIcon: Image
    let texts: [String]

    var body: some View {
        ZStack {
            backgroundColor
                .cornerRadius(20)
                .shadow(color: .paleGray, radius: 30)
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Spacer()
                    icon
                }
                .padding(.top, -50)
                Text(title)
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 5)
                ForEach(texts, id: \.self) { text in
                    HStack {
                        textIcon
                        Text(text)
                            .bold()
                        Spacer()
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}
