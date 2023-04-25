//
//  ContentView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 14.01.2023.
//

import SwiftUI
import RealmSwift

struct ZikrsView: View {
    let out: (Zikr) -> Void
    @ObservedResults(Zikr.self) private var zikrs
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
                        ForEach(zikrs) { zikr in
                            ZikrView(zikr: zikr)
                                .frame(width: (gr.size.width - 60) / 2, height: 300)
                                .onTapGesture {
                                    out(zikr)
                                }
                        }
                        
                    }
                    .animation(.none)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 20)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ZikrsView { _ in }
    }
}
