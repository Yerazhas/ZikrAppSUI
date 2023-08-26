//
//  MainView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 17.01.2023.
//

import SwiftUI

typealias MainOut = (MainOutCmd) -> Void
enum MainOutCmd {
    case openZikr(Zikr)
    case openDua(Dua)
    case openWird(Wird)
    case openSettings
    case openAddNew
    case openPaywall
}

struct MainView: View {
    @AppStorage("isOnboarded") private var isOnboarded: Bool = false
    let out: MainOut
    @State private var currentIndex: Int = 0

    var body: some View {
        TabView(selection: $currentIndex) {
            CounterView()
                .animation(.none)
                .tag(0)
            ZikrsContainerView { outCmd in
                switch outCmd {
                case .openZikr(let zikr):
                    out(.openZikr(zikr))
                case .openDua(let dua):
                    out(.openDua(dua))
                case .openWird(let wird):
                    out(.openWird(wird))
                case .openSettings:
                    out(.openSettings)
                case .openAddNew:
                    out(.openAddNew)
                }
            }
            .tag(1)
            TrackerView(tabSelection: $currentIndex) { outCmd in
                switch outCmd {
                case .openZikr(let zikr):
                    out(.openZikr(zikr))
                case .openWird(let wird):
                    out(.openWird(wird))
                case .openPaywall:
                    out(.openPaywall)
                }
            }
                .tag(2)
        }
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
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView { _ in }
    }
}
