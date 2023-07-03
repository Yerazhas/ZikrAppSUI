//
//  NewMainView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 25.06.2023.
//

import SwiftUI
import RealmSwift

typealias NewMainOut = (NewMainOutCmd) -> Void
enum NewMainOutCmd {
    case open(ZikrType)
    case openSettings
    case openAddNew
}

struct NewMainView: View {
    @AppStorage("isOnboarded") private var isOnboarded: Bool = false
    @Environment(\.colorScheme) private var colorScheme

    @ObservedResults(Wird.self) private var wirds
    @ObservedResults(Zikr.self) private var zikrs
    @ObservedResults(Dua.self) private var duas

    let out: NewMainOut
    @State private var currentIndex: Int = 0
    private let columns = [
        GridItem(.fixed(100))
    ]

    var body: some View {
        TabView(selection: $currentIndex) {
            CounterView()
                .tag(0)
            ZikrsContainerView { outCmd in
//                switch outCmd {
//                case .openZikr(let zikr):
//                    out(.openZikr(zikr))
//                case .openDua(let dua):
//                    out(.openDua(dua))
//                case .openWird(let wird):
//                    out(.openWird(wird))
//                case .openSettings:
//                    out(.openSettings)
//                case .openAddNew:
//                    out(.openAddNew)
//                }
            }
            .tag(1)
            profileView
            .tag(2)
        }
        .navigationBarHidden(true)
        .animation(.default)
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .onAppear {
            guard !isOnboarded else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                currentIndex = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    currentIndex = 0
                    isOnboarded = true
                }
            }
        }
    }

    private var profileView: some View {
        ZStack {
            Color.paleGray
                .ignoresSafeArea(.all)
            ScrollView {
                VStack {
                    headerView
                    Spacer()
                        .frame(height: 20)
                    LazyHGrid(rows: columns, spacing: 10) {
                        ForEach(MainCategory.availableCategories, id: \.title) { category in
                            MainCategoryView(category: category)
                                .frame(width: 100, height: 100)
                                .cornerRadius(20)
                                .onTapGesture {
                                    out(.open(category.type))
                                }
                        }
                    }
                    .animation(.none)
                    .padding(.vertical, 20)

                    statisticsView

                    recentView
                        .padding(.top, 35)
                }
                .padding()
                Spacer()
            }
        }
    }

    private var headerView: some View {
        HStack(spacing: 10) {
            Button {
                out(.openSettings)
            } label: {
                Image("ic-menu")
                    .renderingMode(.template)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button {
                out(.openAddNew)
            } label: {
                Image("ic-add")
                    .renderingMode(.template)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var statisticsView: some View {
        HStack {
            let zikrsCount = zikrs.map { $0.totalDoneCount }.reduce(0, +)
            let duasCount = duas.map { $0.totalDoneCount }.reduce(0, +)
            let wirdsCount = wirds.map { $0.totalDoneCount }.reduce(0, +)
            MainStatisticsView(title: "Total done", text: "\(zikrsCount + duasCount + wirdsCount)")
            MainStatisticsView(title: "Duas done", text: "\(duasCount)")
//            MainStatisticsView(title: "Wirds done", text: "\(wirdsCount)")
        }
    }

    private var recentView: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Recent")
                    .font(.largeTitle)
                Spacer()
            }
            if let lastWird = wirds.last {
                WirdView(wird: lastWird)
            }
            HStack(spacing: 10) {
                if let lastZikr = zikrs.first {
                    ZikrView(zikr: lastZikr)
                        .frame(height: 300)
                }
                if let lastDua = duas.first {
                    ZikrView(zikr: lastDua)
                        .frame(height: 300)
                }
            }
        }
    }
}

struct NewMainView_Previews: PreviewProvider {
    static var previews: some View {
        NewMainView { _ in }
    }
}
