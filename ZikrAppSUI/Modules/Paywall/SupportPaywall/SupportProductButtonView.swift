//
//  SupportProductButtonView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 18.08.2023.
//

import SwiftUI
import Qonversion

struct SupportProductButtonView: View {
    @Environment(\.colorScheme) private var colorScheme
    let product: PurchasingProduct
    let isSelected: Bool
    let tapAction: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            Button {
                tapAction()
            } label: {
                HStack {
                    Spacer()
                    Text(product.prettyPrice)
                        .font(.title3)
                        .foregroundColor(isSelected ? .white : .systemGreen)
                    Spacer()
                }
            }

        }
        .padding(EdgeInsets(top: 17, leading: 20, bottom: 16, trailing: 0))
        .frame(minHeight: 50)
        .background {
            (isSelected ? .systemGreen : Color(.systemBackground))
                .cornerRadius(16)
                .layoutPriority(-1)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isSelected ? Color.systemGreen.opacity(0.5) : Color.textGray.opacity(0.2),
                    lineWidth: 1
                )
        )
    }
}

//struct SupportProductButtonView_Previews: PreviewProvider {
//    static var previews: some View {
//        SupportProductButtonView()
//    }
//}
