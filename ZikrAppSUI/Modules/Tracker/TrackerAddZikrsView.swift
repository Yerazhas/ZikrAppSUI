//
//  TrackerZikrsView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 14.09.2023.
//

import SwiftUI
import RealmSwift

typealias TrackerAddZikrsOut = (TrackerAddZikrsOutCmd) -> Void
enum TrackerAddZikrsOutCmd {
    case zikr(Zikr)
    case dua(Dua)
    case wird(Wird)
}

struct TrackerAddZikrsView: View {
    @ObservedResults(Zikr.self) private var zikrs
    @ObservedResults(Dua.self) private var duas
    @ObservedResults(Wird.self) private var wirds
    private let columns = [
        GridItem(.flexible(minimum: 100)),
        GridItem(.flexible(minimum: 100))
    ]
    let out: TrackerAddZikrsOut

    var body: some View {
        ZStack {
            Color.paleGray
                .ignoresSafeArea(.all)
            GeometryReader { gr in
                ScrollView {
                    VStack(spacing: 0) {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(zikrs) { zikr in
                                ZikrView(zikr: zikr)
                                    .frame(width: (gr.size.width - 30) / 2, height: 300)
                                    .onTapGesture {
                                        hapticLight()
                                        out(.zikr(zikr))
                                    }
                            }
                            ForEach(duas) { dua in
                                ZikrView(zikr: dua)
                                    .frame(width: (gr.size.width - 30) / 2, height: 300)
                                    .onTapGesture {
                                        hapticLight()
                                        out(.dua(dua))
                                    }
                            }
                        }
                        .animation(.none)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        LazyVStack {
                            ForEach(wirds) { wird in
                                WirdView(wird: wird)
                                    .onTapGesture {
                                        hapticLight()
                                        out(.wird(wird))
                                    }
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10)
                    }
                }
            }
        }
    }
}

extension TrackerAddZikrsView: Hapticable {}

struct TrackerAddZikrsView_Previews: PreviewProvider {
    static var previews: some View {
        TrackerAddZikrsView { _ in }
    }
}
