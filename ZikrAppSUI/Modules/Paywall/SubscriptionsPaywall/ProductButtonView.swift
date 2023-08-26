//
//  ProductButtonView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 14.08.2023.
//

import SwiftUI
import Qonversion

struct ProductButtonView: View {
    @Environment(\.colorScheme) private var colorScheme
    let product: Qonversion.Product
    let isSelected: Bool
    let tapAction: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            Button {
                tapAction()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(product.localizedPeriod ?? "")
                            .font(.title3)
                            .bold()
                        Text(product.prettyPrice)
                            .font(.title3)
                    }
                    .foregroundColor(isSelected ? .white : .systemGreen)
                    Spacer()
                    makeSubscriptionDescription()
                }
            }

        }
        .padding(EdgeInsets(top: 17, leading: 20, bottom: 16, trailing: 0))
        .frame(minHeight: 88)
        .background {
            (isSelected ? .systemGreen : Color(.systemBackground))
                .cornerRadius(16)
                .layoutPriority(-1)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isSelected ? Color.systemGreen.opacity(0.5) : Color.textGray.opacity(0.2),
                    lineWidth: 2
                )
        )
    }

    @ViewBuilder
    private func makeSubscriptionDescription() -> some View {
        Text(product.subscriptionDescription ?? "")
            .frame(maxWidth: 200)
            .frame(alignment: .trailing)
            .multilineTextAlignment(.trailing)
            .font(.caption)
            .foregroundColor(isSelected ? .white : .secondary)
    }
}

//struct ProductButtonView_Previews: PreviewProvider {
//    static var previews: some View {
//
//    }
//}
