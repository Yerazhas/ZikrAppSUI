//
//  ZikrTapView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 15.01.2023.
//

import SwiftUI

struct ZikrTapView: View {
    @AppStorage("shouldHideZikrAmount") private var shouldHideZikrAmount: Bool = false
    @AppStorage("language") private var language = LocalizationService.shared.language
    @StateObject private var viewModel: ZikrTapViewModel
    @AppStorage("themeFirstColor") private var themeFirstColor = ThemeService.shared.firstColor
    @AppStorage("themeSecondColor") private var themeSecondColor: String?
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPresented: Bool = false
    @State private var isAmountAlertPresented: Bool = false
    @State private var currentIndex: Int = 0
    @State private var image: UIImage?
    @State private var isPresentingShareSheet = false

    init(zikr: Zikr, out: @escaping ZikrTapOut) {
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
                    if !viewModel.isTapViewExpanded {
                        zikrContentView(gr)
                        .padding(.horizontal)
                    }
                    zikrTapView(gr)
                        .frame(
                            height: viewModel.isTapViewExpanded ? getExpandedHeight(gr) : getHeights(gr).1
                        )
                }
            }
            .confirmationDialog(
                "",
                isPresented: $isPresented
            ) {
                if viewModel.zikr.isDeletable {
                    Button("delete".localized(language)) {
                        viewModel.deleteZikr()
                    }
                }
                Button("share".localized(language)) {
                    hapticLight()
                    renderShareContent(gr: gr)
                }
            } message: {}
        }
        .ignoresSafeArea(.keyboard)
        .onAppear(perform: viewModel.onAppear)
        .alert(
            "Enter everyday zikr amount".localized(language),
            isPresented: $isAmountAlertPresented
        ) {
            TextField("For example, 33", text: $viewModel.dailyAmount)
                .keyboardType(.decimalPad)
            Button("OK", action: {
                viewModel.setAmount()
            })
        } message: {}
            .sheet(isPresented: $isPresentingShareSheet) {
                if #available(iOS 16.0, *) {
                    ZikrSharePreviewView(image: image!)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                } else {
                    ZikrSharePreviewView(image: image!)
                }
            }
    }

    private func renderShareContent(gr: GeometryProxy) {
//        let renderer = ImageRenderer(content: zikrContentView(gr))
//        self.image = zikrContentView(gr).snapshot()
        self.image = ZikrShareView(zikr: viewModel.zikr, gr: gr).asImage
        isPresentingShareSheet = true
    }

    private var headerView: some View {
        HStack {
            Button {
                hapticLight()
//                viewModel.deleteZikr()
                isAmountAlertPresented = true
            } label: {
                Image(systemName: "calendar")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.secondary)
            }
            .padding(.leading)
            Text(viewModel.dailyAmountStatusString)
                .font(.footnote)
                .bold()
                .padding(.leading)
            Spacer()
            Button {
                hapticLight()
                isPresented = true
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.secondary)
            }
            .padding(.trailing)
            Button {
                viewModel.willDisappear()
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
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: getHeights(gr).0)
        }
    }

    private func zikrTapView(_ gr: GeometryProxy) -> some View {
        ZStack {
            makeLinearGradient(themeFirstColor: themeFirstColor, themeSecondColor: themeSecondColor)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 10)
            VStack {
                HStack {
                    Spacer()
                    Button {
                        viewModel.openPaywallIfNeeded()
                    } label: {
                        makeExpandButtonImage()
                    }
                    .padding(.trailing, 30)
                    .padding(.top)
                }
                Spacer()
            }
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
        .onTapGesture {
            viewModel.zikrDidTap()
        }
    }

    @ViewBuilder
    private func makeExpandButtonImage() -> some View {
        let systemName: String
        if viewModel.isTapViewExpanded {
            systemName = "arrow.down.right.and.arrow.up.left"
        } else {
            systemName = "arrow.up.left.and.arrow.down.right"
        }
        return Image(systemName: systemName)
            .renderingMode(.template)
            .schemeAdapted(colorScheme: colorScheme)
    }

    private func getHeights(_ gr: GeometryProxy) -> (CGFloat, CGFloat) {
        let availableHeight = gr.size.height - 24 - 15 - 30
        let upperContainerHeight = availableHeight * 3 / 5
        let lowerContainerHeight = availableHeight * 2 / 5
        return (upperContainerHeight, lowerContainerHeight)
    }

    private func getExpandedHeight(_ gr: GeometryProxy) -> CGFloat {
        let availableHeight = gr.size.height - 24 - 15 - 5
        return availableHeight
    }
}

extension ZikrTapView: Hapticable {}

struct ZikrTapView_Previews: PreviewProvider {
    static var previews: some View {
        ZikrTapView(zikr: Zikr()) { _ in }
    }
}
