//
//  QazaTrackerView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 30.09.2023.
//

import SwiftUI

enum QazaType: String {
    case normal
    case safar
}

struct QazaTrackerView: View {
    @Environment(\.colorScheme) private var colorScheme
    private let columns = [
        GridItem(.flexible(minimum: 100)),
        GridItem(.flexible(minimum: 100))
    ]
    @State private var qazaType: QazaType = .normal
    @AppStorage("language") private var language = LocalizationService.shared.language
    @State private var isQazaModifyPresented: Bool = false
    @StateObject private var viewModel: QazaTrackerViewModel

    init(out: @escaping QazaTrackerOut) {
        _viewModel = .init(wrappedValue: .init(out: out))
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                headerView
                Divider()
                ZStack {
                    Color.paleGray
                    GeometryReader { gr in
                        VStack {
                            switch qazaType {
                            case .normal:
                                ScrollView {
                                    LazyVGrid(columns: columns, spacing: 10) {
                                        ForEach(viewModel.qazaPrayers, id: \.qazaPrayer.id) { vm in
                                            QazaView(qazaPrayer: vm.qazaPrayer)
                                                .frame(width: (gr.size.width - 30) / 2, height: 130)
                                                .onTapGesture {
                                                    hapticLight()
                                                    isQazaModifyPresented = true
                                                    viewModel.selectQazaPrayer(vm.qazaPrayer)
                                                }
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 10)
                                }
                            case .safar:
                                ScrollView {
                                    LazyVGrid(columns: columns, spacing: 10) {
                                        ForEach(viewModel.safarQazaPrayers, id: \.qazaPrayer.id) { vm in
                                            QazaView(qazaPrayer: vm.qazaPrayer)
                                                .frame(width: (gr.size.width - 30) / 2, height: 130)
                                                .onTapGesture {
                                                    hapticLight()
                                                    isQazaModifyPresented = true
                                                    viewModel.selectQazaPrayer(vm.qazaPrayer)
                                                }
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 10)
                                }
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isQazaModifyPresented) {
            if #available(iOS 16.0, *) {
                if let selectedQazaPrayer = viewModel.selectedQazaPrayer {
                    QazaModifyView(qazaPrayer: selectedQazaPrayer, out: { cmd in
                        switch cmd {
                        case .openPaywall:
                            viewModel.openPaywall()
                        case .update(let modifiedQazaPrayer):
                            viewModel.updateQazaPrayer(to: modifiedQazaPrayer)
                        }
                    })
                        .presentationDetents([.height(170)])
                        .presentationDragIndicator(.visible)
                }
            } else {
                if let selectedQazaPrayer = viewModel.selectedQazaPrayer {
                    QazaModifyView(qazaPrayer: selectedQazaPrayer) { cmd in
                        switch cmd {
                        case .openPaywall:
                            viewModel.openPaywall()
                        case .update(let modifiedQazaPrayer):
                            viewModel.updateQazaPrayer(to: modifiedQazaPrayer)
                        }
                    }
                }
            }
        }
        .onChange(of: qazaType) { _ in
            hapticLight()
        }
    }

    private var headerView: some View {
        HStack(spacing: 10) {
            Spacer()
            Button {
                
            } label: {
                Image("ic-add")
                    .renderingMode(.template)
                    .foregroundColor(.secondary)
            }
            .opacity(0)
            Picker(selection: $qazaType) {
                Text("normalQaza".localized(language))
                    .tag(QazaType.normal)
                Text("safarQaza".localized(language))
                    .tag(QazaType.safar)
            } label: {
                EmptyView()
            }
            .pickerStyle(.segmented)
            .padding()
            Button {
                hapticLight()
                viewModel.resetQazas()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .renderingMode(.template)
                    .foregroundColor(.secondary)
            }
            .schemeAdapted(colorScheme: colorScheme)
            Spacer()
        }
    }
}

extension QazaTrackerView: Hapticable {}

//#Preview {
//    QazaTrackerView { _ in }
//}
