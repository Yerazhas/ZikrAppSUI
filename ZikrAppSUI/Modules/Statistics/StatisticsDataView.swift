//
//  StatisticsDataView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 01.08.2023.
//

import SwiftUI

struct StatisticsDataView: View {
    let title: String
    let subtitle: String

    var body: some View {
        ZStack {
            Color.paleGray
                .cornerRadius(10)
            VStack(alignment: .center, spacing: 10) {
                Text(title)
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .minimumScaleFactor(0.5)
                Text(subtitle)
                    .foregroundColor(.secondary)
                    .font(.callout)
            }
            .padding()
        }
    }
}

struct StatisticsDataView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsDataView(title: "176", subtitle: "Total zikrs so far")
    }
}
