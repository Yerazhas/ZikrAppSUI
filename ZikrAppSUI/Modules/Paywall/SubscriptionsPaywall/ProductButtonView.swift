//
//  ProductButtonView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 14.08.2023.
//

import SwiftUI
import Qonversion

struct ProductButtonView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    @Environment(\.colorScheme) private var colorScheme
    let product: PaywallProduct
    let isSelected: Bool
    let tapAction: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            Button {
                tapAction()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ZikrApp \(product.localizedPeriod ?? "")")
                            .font(.title3)
                            .bold()
                            .foregroundColor(isSelected ? .white : .primary)
                            .multilineTextAlignment(.leading)
                        Text(product.subtitle ?? "")
                            .font(.footnote)
                            .foregroundColor(isSelected ? .white : .secondary)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                    if let fullPrice = product.fullPrice {
                        Text(fullPrice)
                            .foregroundColor(isSelected ? .white : .secondary)
                            .overlay(
                                GeometryReader { g in
                                    Path { path in
                                        path.move(to: CGPoint(x: 0, y: g.size.height - 2))
                                        path.addLine(to: CGPoint(x: g.size.width, y: 2))
                                    }
                                    .stroke(Color(hex: 0xFF476C), lineWidth: 2)
                                }
                            )
                    }
                    Text(product.prettyPrice)
                        .font(.title3)
                        .bold()
                        .foregroundColor(isSelected ? .white : .primary)
                        .padding(.trailing)
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
            if let discount = product.discount {
                badgeView(title: "-\(discount)")
                    .offset(x: 0, y: -12)
                    .zIndex(1)
            }
            
            if product.isMostPopular {
                badgeView(title: "mostPopular".localized(language))
                    .offset(x: -56, y: -12)
                    .zIndex(1)
            }
        }
    }

    private func badgeView(title: String) -> some View {
        HStack {
            Spacer()
            Text(title)
                .foregroundColor(.black)
                .font(.caption2)
                .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
                .background(
                    LinearGradient(
                        colors: [
                            Color(hex: 0xFFC938),
                            Color(hex: 0xFFDE83),
                            Color(hex: 0xFFC833)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .cornerRadius(10)
                )
                .padding(.trailing, 10)
        }
    }

    @ViewBuilder
    private func makeSubscriptionDescription() -> some View {
        Text(product.subtitle ?? "")
//            .frame(maxWidth: 200)
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
