//
//  ZikrTapView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 15.01.2023.
//

import SwiftUI

struct ZikrTapView: View {
    @AppStorage("shouldHideZikrAmount") private var shouldHideZikrAmount: Bool = false
    @StateObject private var viewModel: ZikrTapViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentIndex: Int = 0

    init(zikr: Zikr, out: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: .init(zikr: zikr, out: out))
    }

    var body: some View {
        GeometryReader { gr in
            ZStack {
                Color.paleGray
                    .ignoresSafeArea(.all)
                VStack(spacing: 15) {
                    headerView
                    .padding(.top, 5)
                    zikrContentView(gr)
                    .padding(.horizontal)
                    zikrTapView(gr)
                    .frame(height: getHeights(gr).1)
                }
            }
        }
        .onAppear(perform: viewModel.onAppear)
    }

    private var headerView: some View {
        HStack {
            Spacer()
            Button {
                viewModel.willDisappear()
            } label: {
                Image(systemName: "xmark.circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.textGray)
            }
            .padding(.horizontal)
        }
    }

    private func zikrContentView(_ gr: GeometryProxy) -> some View {
        ZStack {
            Color(.systemBackground)
                .cornerRadius(10)
                .shadow(color: Color(.lightGray).opacity(0.1), radius: 3)
            TabView(selection: $currentIndex) {
                ZikrContentView(zikr: viewModel.zikr)
                    .tag(0)
            }
            .cornerRadius(10)
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: getHeights(gr).0)
        }
    }

    private func zikrTapView(_ gr: GeometryProxy) -> some View {
        ZStack {
            Color.systemGreen
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 10)
            VStack(spacing: 0) {
                Spacer()
                Group {
                    Text("\(viewModel.count)")
                        .font(.system(size: 80))
                    if !shouldHideZikrAmount {
                        Text("\(viewModel.totalCount)")
                    }
                }
                .schemeAdapted(colorScheme: colorScheme)
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
        .onTapGesture {
            viewModel.zikrDidTap()
        }
    }

    private func getHeights(_ gr: GeometryProxy) -> (CGFloat, CGFloat) {
        let availableHeight = gr.size.height - 24 - 15 - 30
        let upperContainerHeight = availableHeight * 3 / 5
        let lowerContainerHeight = availableHeight * 2 / 5
        return (upperContainerHeight, lowerContainerHeight)
    }
}

struct ZikrTapView_Previews: PreviewProvider {
    static var previews: some View {
        ZikrTapView(zikr: Zikr()) {}
    }
}
