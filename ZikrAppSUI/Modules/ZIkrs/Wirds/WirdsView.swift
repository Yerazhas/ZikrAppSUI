//
//  WirdsView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 17.01.2023.
//

import SwiftUI
import RealmSwift

struct WirdsView: View {
    let out: (Wird) -> Void
    @AppStorage("language") private var language = LocalizationService.shared.language
    @ObservedResults(Wird.self) private var wirds

    var body: some View {
        ZStack {
            Color.paleGray
                .ignoresSafeArea(.all)
            GeometryReader { gr in
                ScrollView {
                    LazyVStack {
                        ForEach(wirds) { wird in
                            WirdView(wird: wird)
                                .onTapGesture {
                                    hapticLight()
                                    out(wird)
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

extension WirdsView: Hapticable {}

struct WirdsView_Previews: PreviewProvider {
    static var previews: some View {
        WirdsView { _ in }
    }
}
