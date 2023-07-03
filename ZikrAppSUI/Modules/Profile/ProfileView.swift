//
//  ProfileView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 01.07.2023.
//

import SwiftUI
import RealmSwift

struct ProfileView: View {
    @ObservedResults(Wird.self) private var wirds
    @ObservedResults(Zikr.self) private var zikrs
    @ObservedResults(Dua.self) private var duas

    let out: NewMainOut
    @State private var currentIndex: Int = 0
    private let columns = [
        GridItem(.fixed(100))
    ]

    var body: some View {
        ZStack {
            Color.paleGray
                .ignoresSafeArea(.all)
            ScrollView {
                VStack {
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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView { _ in
            
        }
    }
}
