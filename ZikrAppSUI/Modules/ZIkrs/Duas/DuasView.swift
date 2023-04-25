//
//  DuasView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 15.01.2023.
//

import SwiftUI
import RealmSwift

struct DuasView: View {
    let out: (Dua) -> Void
    @ObservedResults(Dua.self) private var duas
    private let columns = [
        GridItem(.flexible(minimum: 100)),
        GridItem(.flexible(minimum: 100))
    ]

    var body: some View {
        ZStack {
            Color.paleGray
                .ignoresSafeArea(.all)
            GeometryReader { gr in
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(duas) { dua in
                            ZikrView(zikr: dua)
                                .frame(width: (gr.size.width - 60) / 2, height: 300)
                                .onTapGesture {
                                    out(dua)
                                }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 20)
                }
            }
        }
        .animation(.none)
    }
}


struct DuasView_Previews: PreviewProvider {
    static var previews: some View {
        DuasView { _ in }
    }
}
