//
//  SettingsView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 15.01.2023.
//

import SwiftUI
import UIKit
import Factory

struct SettingsView: View {
    @AppStorage("isNotificationEnabled") private var isNotificationEnabled: Bool = false
    @AppStorage("shouldHideZikrAmount") private var shouldHideZikrAmount: Bool = false
    @AppStorage("dailyNotificationsAmount") private var dailyNotificationsAmount: Int = 1
    @AppStorage("language") private var language = LocalizationService.shared.language
    @Injected(Container.analyticsService) private var analyticsService
    @StateObject private var viewModel: SettingsViewModel
    @State private var isPresentingShareSheet: Bool = false
    @State private var isPresentingLanguageSheet: Bool = false

    init() {
        _viewModel = StateObject(wrappedValue: .init())
    }

    var body: some View {
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
        VStack {
            Form {
                Section {
                    Toggle(isOn: toggle) {
                        Text("notifications".localized(language))
                    }
                    if isNotificationEnabled {
                        if viewModel.isFirstDateSet {
                            DatePicker("firstDate".localized(language), selection: $viewModel.firstDate, displayedComponents: .hourAndMinute)
                                .datePickerStyle(CompactDatePickerStyle())
                                .onReceive(viewModel.$firstDate) { date in
                                    viewModel.scheduleFirstNotification()
                                }
                        } else {
                            Button {
                                viewModel.isFirstDateSet = true
                            } label: {
                                Text("selectFirstDate".localized(language))
                            }
                        }
                        if viewModel.isSecondDateSet {
                            DatePicker("secondDate".localized(language), selection: $viewModel.secondDate, displayedComponents: .hourAndMinute)
                                .datePickerStyle(CompactDatePickerStyle())
                                .onReceive(viewModel.$secondDate) { date in
                                    viewModel.scheduleSecondNotification()
                                }
                        } else {
                            Button {
                                viewModel.isSecondDateSet = true
                            } label: {
                                Text("selectSecondDate".localized(language))
                            }
                        }
                    }
                }
                Section {
                    Button(action: {
                        isPresentingLanguageSheet = true
                    }) {
                        Text("changeLanguage".localized(language))
                            .foregroundColor(.primary)
                    }
                    Toggle(isOn: $shouldHideZikrAmount) {
                        Text("hideZikrNumbers".localized(language))
                    }
                }
                Section {
                    Button(action: {
                        share()
                    }) {
                        Text("share".localized(language))
                    }
                    Button(action: {
                        openInstagram()
                    }) {
                        Text("followInstagram".localized(language))
                    }
                    Button(action: {
                        rateApp()
                    }) {
                        Text("rateApp".localized(language))
                    }
                }
            }
            .sheet(
                isPresented: $isPresentingShareSheet, content: {
                    ShareSheet(
                        activityItems: [
                            "https://apps.apple.com/kz/app/zikrapp-dhikr-dua-tasbih/id1590270292"
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
            Spacer()
            Text(String(format: "appInfo".localized(language), Bundle.versionString()))
                .multilineTextAlignment(.center)
                .font(.callout)
                .foregroundColor(.secondary)
                .padding(.bottom)
        }
        .onAppear(perform: viewModel.onAppear)
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

    private func rateApp() {
        analyticsService.trackRateApp()
        let url = URL(string: "https://apps.apple.com/kz/app/zikrapp-dhikr-dua-tasbih/id1590270292")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

extension Bundle {
    static func versionString() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
}
