//
//  TrackerQazaPrayerView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 08.10.2023.
//

import SwiftUI

struct TrackerQazaPrayerView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    @AppStorage("themeFirstColor") private var themeFirstColor = ThemeService.shared.firstColor
    @AppStorage("themeSecondColor") private var themeSecondColor: String?
    let viewModel: QazaViewModel
    let date: Date

    var body: some View {
        GeometryReader { gr in
            ZStack(alignment: .leading) {
                
                // The main rectangle
                Rectangle()
                    .fill(Color.paleGray)
                    .frame(width: gr.size.width)
                
                // The progress indicator...
                let progress = viewModel.qazaPrayer.getCurrentProgress(for: date)
                let doneAmount = progress?.0 ?? 0
                let targetAmount = progress?.1 ?? viewModel.qazaPrayer.targetAmount
                let min = min(CGFloat(Double(doneAmount) / Double(targetAmount)), 1.0)
                Color.systemGreen
                    .cornerRadius(10)
                    .frame(width: min == 0.0 ? 0 : max(min, 0.04) * gr.size.width)
                HStack {
                    Text(viewModel.qazaPrayer.title.localized(language))
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .minimumScaleFactor(0.5)
                        .padding(.leading)
                    Spacer()
                    if viewModel.isPerformedToday {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.black)
                    }
                    Text("\(doneAmount)/\(targetAmount)")
                        .padding(.trailing)
                }
            }
            .cornerRadius(10)
        }
    }
}

//#Preview {
//    TrackerQazaPrayerView(viewModel: .init(qazaPrayer: .init(), date: .init()), date: .init())
//}
