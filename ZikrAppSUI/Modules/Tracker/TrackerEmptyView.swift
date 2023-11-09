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
            Image("LaunchScreenLogo")
                .resizable()
                .frame(width: 150, height: 150)
            Text("noZikrs".localized(language))
                .foregroundColor(.secondary)
            if isToday {
                Button {
                    action()
                } label: {
                    ZStack {
                        Color.blue
                            .cornerRadius(10)
                        Text("addZikrs".localized(language))
                    }
                }
                .frame(width: 200, height: 44)
                .foregroundColor(.white)
                .font(.title3)
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
