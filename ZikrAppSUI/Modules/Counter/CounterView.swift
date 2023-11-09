//
//  ZikrView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 15.01.2023.
//

import SwiftUI

typealias CounterOut = (CounterOutCmd) -> Void
enum CounterOutCmd {
    case close
}

struct CounterView: View {
    @StateObject private var viewModel: CounterViewModel
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("themeFirstColor") private var themeFirstColor = ThemeService.shared.firstColor
    @AppStorage("themeSecondColor") private var themeSecondColor: String?
    let out: CounterOut

    init(out: @escaping CounterOut) {
        self.out = out
        _viewModel = StateObject(wrappedValue: .init())
    }

    var body: some View {
        ZStack {
            Color.paleGray
                .ignoresSafeArea(.all)
            VStack(spacing: 0) {
                headerView
                    .padding(.top, 5)
                ZStack {
                    makeLinearGradient(themeFirstColor: themeFirstColor, themeSecondColor: themeSecondColor)
                            .cornerRadius(10)
                            .padding()
                    VStack(alignment: .center, spacing: 0) {
                        Spacer()
                        Text("\(viewModel.count)")
                            .schemeAdapted(colorScheme: colorScheme)
                            .font(.system(size: 80))
                            .fixedSize()
                        Button {} label: {
                            Image(systemName: "arrow.counterclockwise")
                                .renderingMode(.template)
                                .schemeAdapted(colorScheme: colorScheme)
                                .frame(width: 48, height: 48)
                                .padding(.top, 10)
                                .onLongPressGesture {
                                    viewModel.reset()
                                }
                        }

                        Spacer()
                    }
                }
            }
        }
        .animation(.none)
        .onTapGesture {
            viewModel.zikrDidTap()
        }
        .onAppear(perform: viewModel.onAppear)
        .onDisappear(perform: viewModel.onDisappear)
        .navigationBarHidden(true)
    }

    private var headerView: some View {
        HStack {
            Spacer()
            Button {
                hapticLight()
                out(.close)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.secondary)
            }
            .padding(.trailing)
        }
    }
}

extension CounterView: Hapticable {}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView { _ in }
    }
}
