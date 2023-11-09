//
//  ProfileView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 24.10.2023.
//

import SwiftUI
import Combine
import Factory

struct ProfileView: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("isNotificationEnabled") private var isNotificationEnabled: Bool = false
    @AppStorage("shouldHideZikrAmount") private var shouldHideZikrAmount: Bool = false
    @AppStorage("dailyNotificationsAmount") private var dailyNotificationsAmount: Int = 1
    @AppStorage("language") private var language = LocalizationService.shared.language
    @StateObject private var viewModel: ProfileViewModel
    @Injected(Container.analyticsService) private var analyticsService
    @Injected(Container.appStatsService) private var appStatsService
    @State private var isPresentingShareSheet: Bool = false
    @State private var isPresentingLanguageSheet: Bool = false
    
    init(out: @escaping ProfileOut) {
        _viewModel = .init(wrappedValue: .init(out: out))
    }
    
    var body: some View {
        ZStack {
            Color.paleGray
                .ignoresSafeArea(.all)
            ScrollView {
                VStack(spacing: 15) {
                    if viewModel.shouldShowBanner {
                        PremiumBannerView {
                            viewModel.openPaywall()
                        }
                    }
                    firstSection()
                    if Locale.current.regionCode == "RU" && appStatsService.showsRI {
                        russiaPaymentSection()
                    }
                    secondSection()
                    thirdSection()
                    Text(String(format: "appInfo".localized(language), Bundle.versionString()))
                        .multilineTextAlignment(.center)
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                        .onTapGesture {
                            viewModel.activateIfPossible()
                        }
                }
                .padding(.horizontal, 10)
                .padding(.vertical)
            }
        }
        .navigationBarHidden(true)
        .sheet(
            isPresented: $isPresentingShareSheet, content: {
                ShareSheet(
                    activityItems: [
                        "shareText".localized(language, args: "https://apps.apple.com/kz/app/zikrapp-dhikr-dua-tasbih/id1590270292")
                    ]
                )
            }
        )
        .actionSheet(isPresented: $isPresentingLanguageSheet) {
            ActionSheet(
                title: Text("changeLanguage".localized(language)),
                buttons: [
                    .default(Text("English")) {
                        LocalizationService.shared.language = .en
                        self.analyticsService.setUserProperties(["locale": Language.en.rawValue])
                    },
                    .default(Text("Қазақша")) {
                        LocalizationService.shared.language = .kz
                        self.analyticsService.setUserProperties(["locale": Language.en.rawValue])
                    },
                    .default(Text("Русский")) {
                        LocalizationService.shared.language = .ru
                        self.analyticsService.setUserProperties(["locale": Language.en.rawValue])
                    },
                    .cancel(Text("cancel".localized(language)))
                ]
            )
        }
    }
    
    @ViewBuilder
    private func firstSection() -> some View {
        let toggle = Binding<Bool> (
            get: { self.isNotificationEnabled },
            set: { newValue in
                self.isNotificationEnabled = newValue
                if newValue {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
                    viewModel.reset()
                } else {
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                }
            }
        )
        ZStack {
            Group {
                colorScheme == .dark ? Color.black : Color.white
            }
            .cornerRadius(20)
            VStack(alignment: .leading, spacing: 0) {
                Toggle(isOn: toggle) {
                    Text("notifications".localized(language))
                        .toggleStyle(SwitchToggleStyle(tint: .red))
                }
                .frame(height: 50)
                if isNotificationEnabled {
                    if viewModel.isFirstDateSet {
                        Divider()
                        DatePicker("firstDate".localized(language), selection: $viewModel.firstDate, displayedComponents: .hourAndMinute)
                            .datePickerStyle(CompactDatePickerStyle())
                            .onReceive(viewModel.$firstDate) { date in
                                viewModel.scheduleFirstNotification()
                            }
                            .frame(height: 44)
                    } else {
                        Divider()
                        Button {
                            viewModel.isFirstDateSet = true
                        } label: {
                            Text("selectFirstDate".localized(language))
                        }
                        .frame(height: 44)
                    }
                    if viewModel.isSecondDateSet {
                        Divider()
                        DatePicker("secondDate".localized(language), selection: $viewModel.secondDate, displayedComponents: .hourAndMinute)
                            .datePickerStyle(CompactDatePickerStyle())
                            .onReceive(viewModel.$secondDate) { date in
                                viewModel.scheduleSecondNotification()
                            }
                            .frame(height: 44)
                    } else {
                        Divider()
                        Button {
                            viewModel.isSecondDateSet = true
                        } label: {
                            Text("selectSecondDate".localized(language))
                        }
                        .frame(height: 44)
                    }
                }
            }
            .padding(.horizontal, 10)
        }
    }
    
    @ViewBuilder
    private func secondSection() -> some View {
        ZStack {
            Group {
                colorScheme == .dark ? Color.black : Color.white
            }
            .cornerRadius(20)
            VStack(alignment: .leading, spacing: 0) {
                languageButton()
                Button {
                    viewModel.setSound(to: .off)
                } label: {
                    HStack {
                        Text("turnOffSound".localized(language))
                        Spacer()
                        if !viewModel.isSoundEnabled {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .frame(height: 44)
                Divider()
                Button {
                    viewModel.setSound(to: .on(1105))
                } label: {
                    HStack {
                        Text("sound1".localized(language))
                        Spacer()
                        if viewModel.isSoundEnabled && viewModel.soundId == 1105 {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .frame(height: 44)
                Divider()
                Button {
                    viewModel.setSound(to: .on(1306))
                } label: {
                    HStack {
                        Text("sound2".localized(language))
                        Spacer()
                        if viewModel.isSoundEnabled && viewModel.soundId == 1306 {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .frame(height: 44)
                Divider()
                Button {
                    viewModel.setSound(to: .on(1057))
                } label: {
                    HStack {
                        Text("sound3".localized(language))
                        Spacer()
                        if viewModel.isSoundEnabled && viewModel.soundId == 1057 {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .frame(height: 44)
                Divider()
                Button {
                    viewModel.setSound(to: .on(1103))
                } label: {
                    HStack {
                        Text("sound4".localized(language))
                        Spacer()
                        if viewModel.isSoundEnabled && viewModel.soundId == 1103 {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .frame(height: 44)
            }
            .padding(.horizontal, 10)
            .foregroundColor(.primary)
        }
    }

    @ViewBuilder
    private func languageButton() -> some View {
        Group {
            Button(action: {
                isPresentingLanguageSheet = true
            }) {
                HStack {
                    Text("changeLanguage".localized(language))
                        .foregroundColor(.primary)
                    Spacer()
                }
            }
            .frame(height: 44)
            Divider()
        }
    }

    @ViewBuilder
    private func russiaPaymentSection() -> some View {
        ZStack {
            Group {
                colorScheme == .dark ? Color.black : Color.white
            }
            .cornerRadius(20)
            VStack(alignment: .leading, spacing: 0) {
                Button(action: {
                    viewModel.openRussiaPaymentTutorial()
                }) {
                    HStack {
                        Text("russiaPayment".localized(language))
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
                .frame(height: 44)
            }
            .padding(.horizontal, 10)
        }
    }

    @ViewBuilder
    private func thirdSection() -> some View {
        ZStack {
            Group {
                colorScheme == .dark ? Color.black : Color.white
            }
            .cornerRadius(20)
            VStack(alignment: .leading, spacing: 0) {
                Button(action: {
                    share()
                }) {
                    HStack {
                        Text("share".localized(language))
                        Spacer()
                    }
                }
                .frame(height: 44)
                Divider()
                Button(action: {
                    openTelegram()
                }) {
                    HStack {
                        Text("contactMe".localized(language))
                        Spacer()
                    }
                }
                .frame(height: 44)
                Divider()
                Button(action: {
                    rateApp()
                }) {
                    HStack {
                        Text("rateApp".localized(language))
                        Spacer()
                    }
                }
                .frame(height: 44)
                Divider()
                if appStatsService.showsRI {
                    Button(action: {
                        viewModel.copyQonversionUserIdToClipboard()
                    }) {
                        HStack {
                            Text("copy".localized(language))
                            Spacer()
                        }
                    }
                    .frame(height: 44)
                }
            }
            .padding(.horizontal, 10)
        }
    }

    private func share() {
        analyticsService.trackShareApp()
        isPresentingShareSheet = true
    }

    private func openInstagram() {
        analyticsService.trackOpenInstagram()
        guard let url = URL(string: "https://www.instagram.com/salam.apps/") else { return }
        UIApplication.shared.open(url)
    }

    private func openTelegram() {
        guard let url = URL(string: "https://t.me/yera_zhas") else { return }
        UIApplication.shared.open(url)
    }

    private func rateApp() {
        analyticsService.trackRateApp()
        let url = URL(string: "https://apps.apple.com/kz/app/zikrapp-dhikr-dua-tasbih/id1590270292")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView { _ in }
    }
}
