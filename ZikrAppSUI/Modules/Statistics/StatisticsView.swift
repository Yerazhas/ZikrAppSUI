//
//  StatisticsView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 01.08.2023.
//

import SwiftUI

struct StatisticsView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    @Environment(\.colorScheme) private var colorScheme
    @StateObject var viewModel: StatisticsViewModel
    private let rows = [
        GridItem(.fixed(1)),
        GridItem(.fixed(1)),
        GridItem(.fixed(1)),
        GridItem(.fixed(1)),
        GridItem(.fixed(1)),
        GridItem(.fixed(1)),
        GridItem(.fixed(1))
    ]
    
    init(comletion: @escaping () -> Void) {
        _viewModel = .init(wrappedValue: .init(completion: comletion))
    }

    var body: some View {
        return ZStack {
            (colorScheme == .dark ? Color.black : Color.white)
                .ignoresSafeArea()
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                ScrollView {
                    VStack {
                        if let warningText = viewModel.mockDataWarningText {
                            Text(warningText)
                                .padding()
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
    //                            .font(.title3)
                        }
                        if viewModel.showsSubscribeButton {
                            Button {
                                viewModel.completion()
                            } label: {
                                ZStack {
                                    Color.blue
                                        .cornerRadius(8)
                                    Text("subscribe".localized(language))
                                        .foregroundColor(.white)
                                        .font(.title2)
                                }
                            }
                            .frame(height: 45)
                            .padding(.horizontal)
                            .padding(.bottom)
                        }
                        HStack {
                            StatisticsDataView(title: "\(viewModel.zikrsAmount)", subtitle: "Zikrs")
                            StatisticsDataView(title: "\(viewModel.duasAmount)", subtitle: "Duas")
                            StatisticsDataView(title: "\(viewModel.collectionsAmount)", subtitle: "Collections")
                        }
                        .padding(.horizontal)
                        HStack {
                            StatisticsDataView(title: "\(viewModel.idealDaysCount)", subtitle: "Ideal days")
                        }
                        .padding(.horizontal)
                        ForEach(viewModel.zikrProgresses) { progressData in
                            makeContributionsView(from: progressData)
                        }
                        ForEach(viewModel.duaProgresses) { progressData in
                            makeContributionsView(from: progressData)
                        }
                        ForEach(viewModel.wirdProgresses) { progressData in
                            makeContributionsView(from: progressData)
                        }
                    }
                }
                .padding(.top, 40)
            }
        }
    }

    @ViewBuilder
    private func makeContributionsView(from progressData: ProgressData) -> some View {
        VStack {
            Text(progressData.title.localized(language))
                .font(.caption)
            LazyHGrid(rows: rows, spacing: 2) {
                ForEach(progressData.progresses) { zikrProgress in
                    if zikrProgress.progress == 0.0 {
                        Rectangle().fill(Color.paleGray)
                            .frame(width: 5, height: 5)
                    } else {
                        Rectangle().fill(Color.systemGreen.opacity(zikrProgress.progress))
                            .frame(width: 5, height: 5)
                    }
                }
            }
        }
        .padding(.top)
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView {}
    }
}
