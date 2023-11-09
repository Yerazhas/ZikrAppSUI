//
//  QazaView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 30.09.2023.
//

import SwiftUI

struct QazaView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    let qazaPrayer: QazaPrayer

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .cornerRadius(10)
                .shadow(color: Color(.lightGray).opacity(0.1), radius: 14)
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: qazaPrayer.prayerType?.imageName ?? "")
                    Text(qazaPrayer.title.localized(language))
                        .bold()
                }
                ZStack {
                    Color.systemGreen
                        .cornerRadius(10)
                    HStack {
                        VStack(alignment: .leading) {
                            Text("remainingQaza".localized(language))
                                .font(.caption2)
                            Text("\(qazaPrayer.targetAmount - qazaPrayer.doneAmount)")
                                .font(.title3)
                                .bold()
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .colorInvert()
                    .padding(.horizontal)
                }
            }
            .padding()
        }
    }
}

//#Preview {
//    QazaView(qazaPrayer: .init())
//}
