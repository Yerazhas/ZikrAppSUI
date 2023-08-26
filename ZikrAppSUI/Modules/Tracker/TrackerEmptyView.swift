//
//  TrackerEmptyView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 03.08.2023.
//

import SwiftUI

struct TrackerEmptyView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    let isToday: Bool
    let action: () -> Void

    var body: some View {
        VStack(spacing: 50) {
            Spacer()
            Image("ic-empty-zikrs")
            Text("You have no zikrs")
                .foregroundColor(.secondary)
            if isToday {
                Button {
                    action()
                } label: {
                    ZStack {
                        Color.blue
                            .cornerRadius(20)
                        Text("Add zikrs".localized(language))
                    }
                }
                .frame(width: 200, height: 60)
                .foregroundColor(.white)
                .font(.title2)
            }
            Spacer()
        }
    }
}

struct TrackerEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        TrackerEmptyView(isToday: true, action: {})
    }
}
