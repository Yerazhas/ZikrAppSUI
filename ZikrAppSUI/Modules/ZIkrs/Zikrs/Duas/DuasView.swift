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
    @AppStorage("language") private var language = LocalizationService.shared.language
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
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(duas) { dua in
                            ZikrView(zikr: dua)
                                .frame(width: (gr.size.width - 30) / 2, height: 300)
                                .onTapGesture {
                                    hapticLight()
                                    out(dua)
                                }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                }
            }
        }
        .animation(.none)
    }
}

extension DuasView: Hapticable {}

struct DuasView_Previews: PreviewProvider {
    static var previews: some View {
        DuasView { _ in }
    }
}
