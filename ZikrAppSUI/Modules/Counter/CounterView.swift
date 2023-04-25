//
//  ZikrView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 15.01.2023.
//

import SwiftUI

struct CounterView: View {
    @StateObject private var viewModel: CounterViewModel
    @Environment(\.colorScheme) private var colorScheme

    init() {
        _viewModel = StateObject(wrappedValue: .init())
    }

    var body: some View {
        ZStack {
            Color.systemGreen
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
        .animation(.none)
        .onTapGesture {
            viewModel.zikrDidTap()
        }
        .onAppear(perform: viewModel.onAppear)
        .onDisappear(perform: viewModel.onDisappear)
    }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView()
    }
}
