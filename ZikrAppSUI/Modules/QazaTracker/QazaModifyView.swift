//
//  QazaModifyView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 07.10.2023.
//

import SwiftUI

struct QazaModifyView: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("language") private var language = LocalizationService.shared.language
    @StateObject private var viewModel: QazaModifyViewModel

    init(qazaPrayer: QazaPrayer, out: @escaping QazaModifyOut) {
        _viewModel = .init(wrappedValue: .init(qazaPrayer: qazaPrayer, out: out))
    }

    var body: some View {
        GeometryReader { gr in
            VStack(alignment: .center, spacing: 15) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(viewModel.qazaPrayer.title.localized(language))
                            .font(.title)
                            .bold()
                        Text(viewModel.lastUpdatedString ?? "")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("\(viewModel.qazaPrayer.targetAmount - viewModel.qazaPrayer.doneAmount)")
                            .font(.title)
                            .bold()
                        Text("remainingQaza".localized(language))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 20)
                GeometryReader { gr in
                    HStack(spacing: 10) {
                        Button {
                            viewModel.increment()
                        } label: {
                            ZStack {
                                Color.secondary.cornerRadius(10)
                                Text("+1 \("qaza".localized(language))")
                                    .bold()
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(width: (gr.size.width - 10) * 0.33, height: 50)
                        Button {
                            viewModel.decrement()
                        } label: {
                            ZStack {
                                Color.systemGreen
                                    .cornerRadius(10)
                                Text("-1 \("qaza".localized(language))")
                                    .bold()
                                    .foregroundColor(colorScheme == .light ? .white : .black)
                            }
                        }
                        .frame(width: (gr.size.width - 10) * 0.67, height: 50)
                    }
                }
                Spacer()
            }
            .padding(15)
        }
    }
}
