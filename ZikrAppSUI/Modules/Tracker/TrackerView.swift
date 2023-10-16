//
//  TrackerView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 23.07.2023.
//

import SwiftUI
import RealmSwift
import Factory

struct TrackerView: View {
    @StateObject private var viewModel: TrackerViewModel
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("language") private var language = LocalizationService.shared.language
    @Injected(Container.appStatsService) private var appStatsService
    @State private var isSupportPaywallPresented: Bool = false
    @State private var isStatisticsPresented: Bool = false

    @State private var isAddZikrsViewPresented: Bool = false
    @State private var isAmountAlertPresented: Bool = false
    @State private var closeSheetWithAlert = false

    @State private var isStatisticsToolTipVisible: Bool = false
    @State private var isManualProgressToolTipVisible: Bool = false
    @State private var isZikrAmountAlertPresented: Bool = false
    @State private var isDuaAmountAlertPresented: Bool = false
    @State private var isWirdAmountAlertPresented: Bool = false
    @State private var isQazaModifyPresented: Bool = false

    private let columns = [
        GridItem(.flexible(minimum: 100))
    ]
    private var tooltipConfig = DefaultTooltipConfig()

    init(out: @escaping TrackerViewOut) {
        _viewModel = .init(wrappedValue: .init(out: out))
        tooltipConfig.defaultConfig()
        _isStatisticsToolTipVisible = .init(initialValue: !appStatsService.didSeeStatisticsToolTip)
        _isManualProgressToolTipVisible = .init(initialValue: !appStatsService.didSeeManualProgressToolTip)
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0, content: {
                HeaderView()
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 10) {
                        if viewModel.zikrs?.isEmpty ?? true &&
                            viewModel.duas?.isEmpty ?? true &&
                            viewModel.wirds?.isEmpty ?? true
                        {
                            TrackerEmptyView(isToday: viewModel.currentDate.isToday, action: addZikrs)
                        } else {
                            HStack {
                                Text("zikrs".localized(language))
                                    .font(.system(size: 16))
                                    .bold()
                                Spacer()
                            }
                            .padding(.horizontal)
                            if let zikrs = viewModel.zikrs {
                                ForEach(zikrs) { zikr in
                                    VStack(spacing: 0) {
                                        TrackerZikrView(zikr: zikr, date: viewModel.currentDate)
                                            .frame(height: 70)
                                            .padding(.horizontal)
                                            .onTapGesture {
                                                viewModel.openZikr(zikr)
                                            }
                                            .onLongPressGesture {
                                                guard viewModel.currentDate.isToday else {
                                                    viewModel.hapticStrong()
                                                    return
                                                }
                                                hapticLight()
                                                viewModel.selectedZikr = zikr
                                                isZikrAmountAlertPresented = true
                                                appStatsService.didSeeManualProgressToolTipPage()
                                                isManualProgressToolTipVisible = false
                                            }
                                    }
                                }
                            }
                            if let duas = viewModel.duas {
                                ForEach(duas) { dua in
                                    VStack {
                                        TrackerZikrView(zikr: dua, date: viewModel.currentDate)
                                            .frame(height: 70)
                                            .padding(.horizontal)
                                            .onTapGesture {
                                                viewModel.openZikr(dua)
                                            }
                                            .onLongPressGesture {
                                                hapticLight()
                                                viewModel.selectedDua = dua
                                                isDuaAmountAlertPresented = true
                                                appStatsService.didSeeManualProgressToolTipPage()
                                                isManualProgressToolTipVisible = false
                                            }
                                    }
                                }
                            }
                            if let wirds = viewModel.wirds {
                                ForEach(wirds) { wird in
                                    VStack {
                                        TrackerWirdView(wird: wird, date: viewModel.currentDate)
                                            .frame(height: 70)
                                            .padding(.horizontal)
                                            .onTapGesture {
                                                viewModel.openWird(wird)
                                            }
                                            .onLongPressGesture {
                                                hapticLight()
                                                viewModel.selectedWird = wird
                                                isWirdAmountAlertPresented = true
                                                appStatsService.didSeeManualProgressToolTipPage()
                                                isManualProgressToolTipVisible = false
                                            }
                                    }
                                }
                            }
                            if !viewModel.qazaPrayers.isEmpty {
                                HStack {
                                    Text("prayers".localized(language))
                                        .font(.system(size: 16))
                                        .bold()
                                    Spacer()
                                    Button {
                                        viewModel.changeFullListShownState()
                                    } label: {
                                        Text(viewModel.isFullQazaPrayersListShown ? "hide".localized(language) : "showAll".localized(language))
                                            .font(.caption)
                                            .bold()
                                    }

                                }
                                .padding(.horizontal)
                                .padding(.top)
                                ForEach(viewModel.qazaPrayers, id: \.qazaPrayer.id) { vm in
                                    VStack {
                                        TrackerQazaPrayerView(viewModel: vm, date: viewModel.currentDate)
                                            .frame(height: 70)
                                            .padding(.horizontal)
                                            .onTapGesture {
                                                guard viewModel.currentDate.isToday else {
                                                    viewModel.hapticStrong()
                                                    return
                                                }
                                                viewModel.selectQazaPrayer(vm.qazaPrayer)
                                                isQazaModifyPresented = true
                                            }
                                            .onLongPressGesture {
    //                                                hapticLight()
    //                                                viewModel.selectedWird = wird
    //                                                isWirdAmountAlertPresented = true
    //                                                appStatsService.didSeeManualProgressToolTipPage()
    //                                                isManualProgressToolTipVisible = false
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .hSpacing(.center)
                    .vSpacing(.center)
                    .tooltip(
                        isManualProgressToolTipVisible && viewModel.hasZikrs,
                        side: .bottom,
                        config: tooltipConfig
                    ) {
                        ZStack {
                            Text("manualProgressSet".localized(language))
                                .font(.caption)
                                .foregroundColor(colorScheme == .dark ? .black : .white)
                        }
                    }
                    .padding(.bottom, 100)
                }
            })
            .animation(.none)
            .vSpacing(.top)
            .navigationBarHidden(true)
            .onAppear(perform: {
                viewModel.onAppear()
            })
            .alert(
                "enterTodaysProgress".localized(language),
                isPresented: $isZikrAmountAlertPresented
            ) {
                TextField("dailyZikrPlaceholder".localized(language), text: $viewModel.zikrProgress)
                    .keyboardType(.decimalPad)
                Button("ok".localized(language), action: {
                    viewModel.zikrDidLongTap()
                })
            } message: {}
                .alert(
                    "enterDailyZikrAmount".localized(language),
                    isPresented: $isWirdAmountAlertPresented
                ) {
                    TextField("dailyZikrPlaceholder".localized(language), text: $viewModel.zikrProgress)
                        .keyboardType(.decimalPad)
                    Button("ok".localized(language), action: {
                        viewModel.wirdDidLongTap()
                    })
                } message: {}
                .alert(
                    "enterDailyZikrAmount".localized(language),
                    isPresented: $isDuaAmountAlertPresented
                ) {
                    TextField("dailyZikrPlaceholder".localized(language), text: $viewModel.zikrProgress)
                        .keyboardType(.decimalPad)
                    Button("ok".localized(language), action: {
                        viewModel.duaDidLongTap()
                    })
                } message: {}
            .sheet(isPresented: $isStatisticsPresented) {
                if #available(iOS 16.0, *) {
                    StatisticsView {
                        viewModel.openPaywall()
                    }
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                } else {
                    StatisticsView {
                        viewModel.openPaywall()
                    }
                }
            }
            .sheet(isPresented: $isQazaModifyPresented) {
                if #available(iOS 16.0, *) {
                    if let selectedQazaPrayer = viewModel.selectedQazaPrayer {
                        QazaModifyView(qazaPrayer: selectedQazaPrayer) { cmd in
                            switch cmd {
                            case .update(let modifiedQazaPrayer):
                                viewModel.updateQazaPrayer(with: modifiedQazaPrayer)
                            case .openPaywall:
                                viewModel.openPaywall()
                            }
                        }
                            .presentationDetents([.height(150)])
                            .presentationDragIndicator(.visible)
                    }
                } else {
                    if let selectedQazaPrayer = viewModel.selectedQazaPrayer {
                        QazaModifyView(qazaPrayer: selectedQazaPrayer) { cmd in
                            switch cmd {
                            case .update(let modifiedQazaPrayer):
                                viewModel.updateQazaPrayer(with: modifiedQazaPrayer)
                            case .openPaywall:
                                viewModel.openPaywall()
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $isAddZikrsViewPresented, onDismiss: {
                isAmountAlertPresented = closeSheetWithAlert
            }) {
                TrackerAddZikrsView { cmd in
                    viewModel.addZikrsCmd = cmd
                    closeSheetWithAlert = true
                    isAddZikrsViewPresented = false
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
            plusButton()
                .padding()
        }
    }

    @ViewBuilder
    func plusButton() -> some View {
        return VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    hapticLight()
                    addZikrs()
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                Color.systemGreen
                            )
                            .shadow(color: Color.systemGreen.opacity(0.6), radius: 5)
                        Image(systemName: "plus")
                            .foregroundColor(colorScheme == .light ? .white : .black)
                    }
                }
                .frame(width: 60, height: 60)
            }
        }
    }

    /// Header View
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 0) {
                VStack(alignment: .leading) {
                    if viewModel.currentDate.isToday {
                        Text("today".localized(language).capitalized)
                            .font(.title3)
                            .fontWeight(.semibold)
                    } else {
                        Text(viewModel.currentDate.format("EEEE, MMM d, yyyy", locale: .init(identifier: language.rawValue)).capitalized)
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
                Spacer()
                Button {
                    viewModel.hapticLight()
                    isStatisticsPresented = true
                    appStatsService.didSeeStatisticsToolTipPage()
                    isStatisticsToolTipVisible = false
                    viewModel.openStatistics()
                } label: {
                    Image(systemName: "chart.xyaxis.line")
                        .renderingMode(.template)
                        .foregroundColor(.primary)
                        .tooltip(
                            isStatisticsToolTipVisible,
                            side: .bottom,
                            config: tooltipConfig
                        ) {
                            ZStack {
                                Text("seeStatistics".localized(language))
                                    .font(.caption)
                                    .foregroundColor(colorScheme == .dark ? .black : .white)
                            }
                        }
                }
                .padding(.trailing, 10)
                Button {
                    hapticLight()
                    isSupportPaywallPresented = true
                    viewModel.openSupportPaywall()
                } label: {
                    Image(systemName: "heart.fill")
                        .renderingMode(.template)
                        .foregroundColor(.red)
                }
                .padding(.trailing, 10)
                Button {
                    hapticLight()
                    guard let url = URL(string: "https://t.me/yera_zhas") else { return }
                    viewModel.contactSupport()
                    UIApplication.shared.open(url)
                } label: {
                    Image(systemName: "message.fill")
                        .renderingMode(.template)
                        .foregroundColor(.primary)
                }
            }
//            .padding(.horizontal)
            .zIndex(1)
            
            /// Week Slider
            TabView(selection: $viewModel.currentWeekIndex) {
                ForEach(viewModel.weekSlider.indices, id: \.self) { index in
                    let week = viewModel.weekSlider[index]
                    WeekView(week)
//                        .padding(.horizontal, 15)
                        .tag(index)
                }
            }
//            .padding(.horizontal, -15)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 90)
        }
        .hSpacing(.leading)
        .padding()
        .onChange(of: viewModel.currentWeekIndex, perform: { newValue in
            print(viewModel.weekSlider.count)
            if newValue == 0 || newValue == (viewModel.weekSlider.count - 1) {
                viewModel.createWeek = true
            }
        })
        .sheet(isPresented: $isSupportPaywallPresented) {
            if #available(iOS 16.0, *) {
                SupportPaywallView {
                    self.isSupportPaywallPresented = false
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            } else {
                SupportPaywallView {
                    self.isSupportPaywallPresented = false
                }
            }
        }
    }
    
    /// Week View
    @ViewBuilder
    func WeekView(_ week: [DayProgress]) -> some View {
        return HStack(spacing: 0) {
            ForEach(week) { progress in
                let day = progress.day
                ZStack {
                    if isSameDate(day.date, viewModel.currentDate) {
                        Capsule()
                            .fill(
                                Color.systemGreen
//                                .opacity(0.5)
                            )
                            .shadow(color: Color.systemGreen.opacity(0.6), radius: 5)
                    }
                    VStack(spacing: 8) {
                        let color: Color = isSameDate(day.date, viewModel.currentDate) ? .white : Color.gray
                        Text(day.date.format("E", locale: .init(identifier: language.rawValue)))
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundColor(color)
                        weekViewDayText(progress: progress)
                            .foregroundColor(.primary)
                    }
                    .hSpacing(.center)
                    .onTapGesture {
                        /// Updating Current Date
                        viewModel.hapticLight()
                        withAnimation {
                            viewModel.currentDate = day.date
                            viewModel.updateZikrs(for: day.date)
                        }
                    }
                }
            }
        }
        .background {
            GeometryReader {
                let minX = $0.frame(in: .global).minX
                
                Color.clear
                    .preference(key: OffsetKey.self, value: minX)
                    .onPreferenceChange(OffsetKey.self) { value in
                        /// When the Offset reaches 15 and if the createWeek is toggled then simply generating next set of week
                        if value.rounded() == 15 && viewModel.createWeek {
                            viewModel.paginateWeek()
                            viewModel.createWeek = false
                        }
                    }
            }
        }
    }

    @ViewBuilder
    private func weekViewDayText(progress: DayProgress) -> some View {
        let day = progress.day
        return Text(day.date.format("dd", locale: .init(identifier: language.rawValue)))
            .font(.callout)
            .fontWeight(.bold)
            .frame(width: 35, height: 35)
            .background(content: {
                ZStack {
                    Circle()
                        .fill(colorScheme == .dark ? .black : .white)
                    makeCircularProgressView(progress: progress)
                    if progress.progress == 1.0 {
                        Image(systemName: "star.fill")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.yellow)
                            .frame(width: 10, height: 10)
                            .padding(.top, -25)
                            .padding(.trailing, -50)
                    }
                }
                
                /// Indicator to Show, Which is Today;s Date
                if day.date.isToday {
                    let color: Color = isSameDate(day.date, viewModel.currentDate) ? .primary : (colorScheme != .dark ? .black : .white)
                    Circle()
                        .fill(color)
                        .frame(width: 5, height: 5)
                        .vSpacing(.bottom)
                        .offset(y: 12)
                        .id(viewModel.currentDayIdentificator)
                }
            })
    }
    

    @ViewBuilder
    private func makeCircularProgressView(progress: DayProgress) -> some View {
        var stops: [Gradient.Stop] = []
        let day = progress.day
        if isSameDate(day.date, viewModel.currentDate) {
            stops = [.init(color: .primary, location: 0.00)]
        } else {
            stops = [.init(color: Color.systemGreen, location: 0.00)]
        }
        let gradient = LinearGradient(
            stops: stops,
            startPoint: UnitPoint(x: 1, y: 0.96),
            endPoint: UnitPoint(x: 0, y: 0)
        )

        return ZStack {
            ZStack {
                    Circle()
                    .stroke(Color.textGray.opacity(0.2), lineWidth: 1)

                    Circle()
                    .trim(from: 0, to: progress.progress)
                        .stroke(gradient, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .overlay(
                            Circle().trim(from: 0, to: progress.progress)
                            .rotation(Angle.degrees(-4))
                            .stroke(gradient, style: StrokeStyle(lineWidth: 2, lineCap: .butt)))
                        .rotationEffect(.degrees(-90))

                }
        }
    }

    private func addZikrs() {
        isAddZikrsViewPresented = true
        closeSheetWithAlert = false
        viewModel.addZikrs()
    }
}

struct TrackerView_Previews: PreviewProvider {
    static var previews: some View {
        TrackerView { _ in }
    }
}

extension TrackerView: Hapticable {}
