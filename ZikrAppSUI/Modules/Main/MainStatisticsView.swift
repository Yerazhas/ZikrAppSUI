//
//  MainStatisticsView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 25.06.2023.
//

import SwiftUI

struct MainStatisticsView: View {
    let title: String
    let text: String

    var body: some View {
        ZStack(alignment: .leading) {
            Color(.systemBackground).cornerRadius(15)
            VStack(alignment: .leading, spacing: 5) {
                Text(text)
                    .font(.largeTitle)
                    .foregroundColor(.systemGreen)
                Text(title)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding()
            
        }
    }
}

struct MainStatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        MainStatisticsView(title: "Total done", text: "97355")
    }
}
