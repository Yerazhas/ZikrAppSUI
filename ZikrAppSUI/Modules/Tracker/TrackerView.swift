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
    @AppStorage("themeFirstColor") private var themeFirstColor = ThemeService.shared.firstColor
    @AppStorage("themeSecondColor") private var themeSecondColor: String?
    @Injected(Container.appStatsService) private var appStatsService
    @Binding var tabSelection: Int
    @State private var isSupportPaywallPresented: Bool = false
    @State private var isStatisticsPresented: Bool = false
    @State private var isStatisticsToolTipVisible: Bool = false
    private let columns = [
        GridItem(.flexible(minimum: 100))
    ]
    private var tooltipConfig = DefaultTooltipConfig()

    init(tabSelection: Binding<Int>, out: @escaping TrackerViewOut) {
        self._tabSelection = tabSelection
        _viewModel = .init(wrappedValue: .init(out: out))
        tooltipConfig.defaultConfig()
        _isStatisticsToolTipVisible = .init(initialValue: !appStatsService.didSeeStatisticsToolTip)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0, content: {
            HeaderView()
            GeometryReader {
                let size = $0.size
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 10) {
                        if viewModel.zikrs?.isEmpty ?? true &&
                            viewModel.duas?.isEmpty ?? true &&
                            viewModel.wirds?.isEmpty ?? true
                        {
                            TrackerEmptyView(isToday: viewModel.currentDate.isToday, action: addZikrs)
                        } else {
                            if let zikrs = viewModel.zikrs {
                                ForEach(zikrs) { zikr in
                                    VStack(spacing: 0) {
                                        TrackerZikrView(zikr: zikr, date: viewModel.currentDate)
                                            .frame(height: 70)
                                            .padding(.horizontal)
                                            .onTapGesture {
                                                viewModel.openZikr(zikr)
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
                                    }
                                }
                            }
                        }
                    }
                    .hSpacing(.center)
                    .vSpacing(.center)
                }
            }
        })
        .animation(.none)
        .vSpacing(.top)
        .onAppear(perform: {
            viewModel.onAppear()
        })
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
    }
    
    /// Header View
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 0) {
                VStack(alignment: .leading) {
                    HStack(spacing: 5) {
                        Text(viewModel.currentDate.format("MMMM", locale: .init(identifier: language.rawValue)))
                        
                        Text(viewModel.currentDate.format("YYYY", locale: .init(identifier: language.rawValue)))
                            .foregroundStyle(.gray)
                    }
                    .font(.title.bold())
                    
                    Text(viewModel.currentDate.format("EEEE, MMM d, yyyy", locale: .init(identifier: language.rawValue)))
                        .font(.callout)
                        .fontWeight(.semibold)
                }
                Spacer()
                Button {
                    viewModel.hapticLight()
                    isStatisticsPresented = true
                    appStatsService.didSeeStatisticsToolTipPage()
                    isStatisticsToolTipVisible = false
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
                .frame(width: 50, height: 50)
                Button {
                    hapticLight()
                    isSupportPaywallPresented = true
                } label: {
                    Image(systemName: "heart.fill")
                        .renderingMode(.template)
                        .foregroundColor(.red)
                }
                .frame(width: 50, height: 50)

            }
            .zIndex(1)
            
            /// Week Slider
            TabView(selection: $viewModel.currentWeekIndex) {
                ForEach(viewModel.weekSlider.indices, id: \.self) { index in
                    let week = viewModel.weekSlider[index]
                    WeekView(week)
                        .padding(.horizontal, 15)
                        .tag(index)
                }
            }
            .padding(.horizontal, -15)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 90)
        }
        .hSpacing(.leading)
        .padding(15)
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
        HStack(spacing: 0) {
            ForEach(week) { progress in
                let day = progress.day
                VStack(spacing: 8) {
                    Text(day.date.format("E", locale: .init(identifier: language.rawValue)))
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundStyle(.gray)
                    if isSameDate(day.date, viewModel.currentDate) {
                        weekViewDayText(progress: progress)
//                            .foregroundColor(colorScheme == .light ? .white : .black)
                            .foregroundColor(.primary)
                    } else {
                        weekViewDayText(progress: progress)
                            .foregroundColor(.primary)
                    }
                    
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
        var stops: [Gradient.Stop] = [.init(color: Color(themeFirstColor), location: 0.00)]
        if let themeSecondColor {
            stops.append(.init(color: Color(themeSecondColor), location: 1.00))
        }
        let day = progress.day
        return Text(day.date.format("dd", locale: .init(identifier: language.rawValue)))
            .font(.callout)
            .fontWeight(.bold)
            .frame(width: 35, height: 35)
            .background(content: {
                ZStack {
                    if isSameDate(day.date, viewModel.currentDate) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    stops: stops,
                                    startPoint: UnitPoint(x: 1, y: 0.96),
                                    endPoint: UnitPoint(x: 0, y: 0)
                                )
                                .opacity(0.5)
                            )
                    }
                    makeCircularProgressView(progress: progress.progress)
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
                    Circle()
                        .fill(.cyan)
                        .frame(width: 5, height: 5)
                        .vSpacing(.bottom)
                        .offset(y: 12)
                        .id(viewModel.currentDayIdentificator)
                }
            })
    }
    

    @ViewBuilder
    private func makeCircularProgressView(progress: CGFloat) -> some View {
        var stops: [Gradient.Stop] = [.init(color: Color(themeFirstColor), location: 0.00)]
        if let themeSecondColor {
            stops.append(.init(color: .init(themeSecondColor), location: 1.00))
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
                    .trim(from: 0, to: progress)
                        .stroke(gradient, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .overlay(
                            Circle().trim(from: 0, to: progress)
                            .rotation(Angle.degrees(-4))
                            .stroke(gradient, style: StrokeStyle(lineWidth: 2, lineCap: .butt)))
                        .rotationEffect(.degrees(-90))

                }
        }
    }

    private func addZikrs() {
        viewModel.hapticLight()
        tabSelection = 1
    }
}

struct TrackerView_Previews: PreviewProvider {
    static var previews: some View {
        TrackerView(tabSelection: .constant(1)) { _ in }
    }
}

extension TrackerView: Hapticable {}
