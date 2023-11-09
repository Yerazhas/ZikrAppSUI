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
    case openAddNew
    case openPaywall
    case openCounter
    case openRussiaPaymentTutorial
}

struct MainView: View {
    let out: MainOut
    @State private var currentIndex: Int = 0

    var body: some View {
        TabView(selection: $currentIndex) {
            TrackerView { outCmd in
                switch outCmd {
                case .openZikr(let zikr):
                    out(.openZikr(zikr))
                case .openWird(let wird):
                    out(.openWird(wird))
                case .openPaywall:
                    out(.openPaywall)
                }
            }
            .tag(0)
            .tabItem {
                Label("Habits", image: "ic-checkmark-1")
            }
            ZikrsContainerView { outCmd in
                switch outCmd {
                case .openZikr(let zikr):
                    out(.openZikr(zikr))
                case .openDua(let dua):
                    out(.openDua(dua))
                case .openWird(let wird):
                    out(.openWird(wird))
                case .openAddNew:
                    out(.openAddNew)
                case .openCounter:
                    out(.openCounter)
                }
            }
            .tag(1)
            .tabItem {
                Label("Zikr", image: "ic-tasbih")
            }
            QazaContainerView(out: { cmd in
                switch cmd {
                case .openPaywall:
                    out(.openPaywall)
                }
            })
                .animation(.none)
                .tag(2)
                .tabItem {
                    Label("Qaza Tracker", image: "ic-qaza")
                }
            ProfileView { cmd in
                switch cmd {
                case .openPaywall:
                    out(.openPaywall)
                case .openRussiaPaymentTutorial:
                    out(.openRussiaPaymentTutorial)
                }
            }
            .tag(3)
            .tabItem {
                Label("Profile", image: "ic-profile")
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .animation(.default)
        .onChange(of: currentIndex) { newIndex in
            hapticLight()
        }
    }
}

extension MainView: Hapticable {}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView { _ in }
    }
}
