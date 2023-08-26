//
//  ZikrsContainerView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 15.01.2023.
//

import SwiftUI
import Factory

typealias ZikrsContainerViewOut = (ZikrsContainerViewOutCmd) -> Void
enum ZikrsContainerViewOutCmd {
    case openZikr(Zikr)
    case openDua(Dua)
    case openWird(Wird)
    case openSettings
    case openAddNew
}

struct ZikrsContainerView: View {
    let out: ZikrsContainerViewOut
    @Environment(\.colorScheme) private var colorScheme
    @State private var contentType: ZikrType = .zikr
    @Injected(Container.localizationService) private var localizationService
    @Injected(Container.analyticsService) private var analyticsService
    @AppStorage("language") private var language = LocalizationService.shared.language

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            switch contentType {
            case .zikr:
                ZikrsView { zikr in
                    out(.openZikr(zikr))
                }
                .onAppear {
                    analyticsService.trackOpenZikrs(zikrType: contentType)
                }
            case .dua:
                DuasView { dua in
                    out(.openDua(dua))
                }
                .onAppear {
                    analyticsService.trackOpenZikrs(zikrType: contentType)
                }
            case .wird:
                WirdsView { wird in
                    out(.openWird(wird))
                }
                .onAppear {
                    analyticsService.trackOpenZikrs(zikrType: contentType)
                }
            }
        }
        .animation(.none)
        .navigationBarHidden(true)
        .onChange(of: contentType) { _ in
            hapticLight()
        }
    }

    private var headerView: some View {
        HStack(spacing: 10) {
            Spacer()
            Button {
                hapticLight()
                out(.openSettings)
            } label: {
                Image("ic-menu")
                    .renderingMode(.template)
                    .foregroundColor(.secondary)
            }
            .schemeAdapted(colorScheme: colorScheme)
            Picker(selection: $contentType) {
                Text("zikrs".localized(language))
                    .tag(ZikrType.zikr)
                Text("duas".localized(language))
                    .tag(ZikrType.dua)
                Text("wirds".localized(language))
                    .tag(ZikrType.wird)
            } label: {
                EmptyView()
            }
            .pickerStyle(.segmented)
            .padding()
            Button {
                hapticLight()
                out(.openAddNew)
            } label: {
                Image("ic-add")
                    .renderingMode(.template)
                    .foregroundColor(.secondary)
            }
            .schemeAdapted(colorScheme: colorScheme)
            Spacer()
        }
    }
}

extension ZikrsContainerView: Hapticable {}

struct ZikrsContainerView_Previews: PreviewProvider {
    static var previews: some View {
        ZikrsContainerView { _ in }
    }
}
