//
//  WirdTapView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 18.01.2023.
//

import SwiftUI

struct WirdTapView: View {
    @StateObject private var viewModel: WirdTapViewModel
    @Environment(\.colorScheme) private var colorScheme

    init(wird: Wird, out: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: .init(wird: wird, out: out))
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
            TabView(selection: $viewModel.currentIndex) {
                ForEach(Array(viewModel.targetedZikrs.enumerated()), id: \.1) { (index, targetedZikr) in
                    ZikrContentView(zikr: targetedZikr.zikr)
                        .tag(index)
                }
            }
            .cornerRadius(10)
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: getHeights(gr).0)
            .animation(.default)
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
                    Text("\(viewModel.currentTargetedZikr.targetAmount)")
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
        .onAppear(perform: viewModel.onAppear)
    }

    private func getHeights(_ gr: GeometryProxy) -> (CGFloat, CGFloat) {
        let availableHeight = gr.size.height - 24 - 15 - 30
        let upperContainerHeight = availableHeight * 3 / 5
        let lowerContainerHeight = availableHeight * 2 / 5
        return (upperContainerHeight, lowerContainerHeight)
    }
}

struct WirdTapView_Previews: PreviewProvider {
    static var previews: some View {
        WirdTapView(wird: .init()) {}
    }
}
