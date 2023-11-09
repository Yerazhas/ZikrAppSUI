//
//  WirdTapView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 18.01.2023.
//

import SwiftUI
import Factory

struct WirdTapView: View {
    @StateObject private var viewModel: WirdTapViewModel
    @State private var isAmountAlertPresented: Bool = false
    @AppStorage("language") private var language = LocalizationService.shared.language
    @AppStorage("themeFirstColor") private var themeFirstColor = ThemeService.shared.firstColor
    @AppStorage("themeSecondColor") private var themeSecondColor: String?
    @Environment(\.colorScheme) private var colorScheme
    @Injected(Container.appStatsService) private var appStatsService
    @State private var image: UIImage?
    @State private var isPresentingShareSheet = false
    @State private var isDailyAmountToolTipVisible: Bool = false
    @State private var isOptionsMenuPresented: Bool = false
    private var tooltipConfig = DefaultTooltipConfig()

    init(wird: Wird, out: @escaping WirdTapOut) {
        _viewModel = StateObject(wrappedValue: .init(wird: wird, out: out))
        tooltipConfig.defaultConfig()
        _isDailyAmountToolTipVisible = .init(initialValue: !appStatsService.didSeeDailyAmountToolTip)
    }

    var body: some View {
        GeometryReader { gr in
            ZStack {
                Color.paleGray
                    .ignoresSafeArea(.all)
                VStack(spacing: 15) {
                    headerView
                    .padding(.top, 5)
                    .zIndex(1)
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
            .alert(
                "enterDailyZikrAmount".localized(language),
                isPresented: $isAmountAlertPresented
            ) {
                TextField("dailyZikrPlaceholder".localized(language), text: $viewModel.dailyAmount)
                    .keyboardType(.decimalPad)
                Button("ok".localized(language), action: {
                    viewModel.setAmount()
                })
            } message: {}
            .confirmationDialog(
                "",
                isPresented: $isOptionsMenuPresented
            ) {
                Button("enterDailyZikrAmount".localized(language)) {
                    isAmountAlertPresented = true
                }
                Button("removeFromTracker".localized(language)) {
                    viewModel.removeFromTracker()
                }
                if viewModel.wird.isDeletable {
                    Button("delete".localized(language)) {
                        viewModel.deleteWird()
                    }
                }
                Button("share".localized(language)) {
                    hapticLight()
                    renderShareContent(gr: gr)
                }
            } message: {
                Text("actions".localized(language))
            }
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
        .ignoresSafeArea(.keyboard)
    }

    private var headerView: some View {
        HStack(spacing: 15) {
            Button {
                hapticLight()
                isOptionsMenuPresented = true
                appStatsService.didSeeDailyAmountToolTipPage()
                isDailyAmountToolTipVisible = false
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.secondary)
                    .tooltip(
                        isDailyAmountToolTipVisible,
                        side: .right,
                        config: tooltipConfig
                    ) {
                        ZStack {
                            Text("setDailyAmount".localized(language))
                                .font(.caption)
                                .foregroundColor(colorScheme == .dark ? .black : .white)
                        }
                    }
            }
            .padding(.leading)
            Text(viewModel.dailyAmountStatusString)
                .font(.footnote)
                .bold()
                .padding(.leading)
            Spacer()
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

    private func renderShareContent(gr: GeometryProxy) {
        self.image = WirdShareView(wird: viewModel.wird, gr: gr).asImage
        isPresentingShareSheet = true
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
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .frame(height: getHeights(gr).0)
            .animation(.default)
        }
    }

    private func zikrTapView(_ gr: GeometryProxy) -> some View {
        ZStack {
            makeLinearGradient(themeFirstColor: themeFirstColor, themeSecondColor: themeSecondColor)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 10)
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        viewModel.expandIfPossible()
                    } label: {
                        makeExpandButtonImage()
                    }
                    .padding(.trailing, 30)
                    .padding(.top)
                }
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
                if viewModel.isTapViewExpanded {
                    PageControl(currentPageIndex: viewModel.currentIndex, numberOfPages: viewModel.targetedZikrs.count)
                        .padding(.bottom)
                }
            }
        }
        .onTapGesture {
            viewModel.zikrDidTap()
        }
        .onAppear(perform: viewModel.onAppear)
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

extension WirdTapView: Hapticable {}

struct WirdTapView_Previews: PreviewProvider {
    static var previews: some View {
        WirdTapView(wird: .init()) { _ in }
    }
}
