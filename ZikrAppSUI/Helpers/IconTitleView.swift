//
//  IconTitleView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 15.08.2023.
//

import SwiftUI

struct IconTitleView: View {
    let title: String

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
//            Image(systemName: "checkmark.square.fill")
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 18, height: 18)
                .foregroundColor(.systemGreen)
                .padding(.top, 5)
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .foregroundColor(.primary)
                    .font(.callout)
                    .bold()
                    .fixedSize(horizontal: false, vertical: true)
//                if let subtitle {
//                    Text(subtitle)
//                        .fixedSize(horizontal: false, vertical: true)
//                        .foregroundColor(.secondaryLabel)
//                }
//                if let linkData {
//                    Link(linkData.title, destination: linkData.link)
//                }
            }
            Spacer()
        }
    }
}
