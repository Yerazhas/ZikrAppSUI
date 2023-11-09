//
//  SplashViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 14.09.2023.
//

import Factory

final class SplashViewModel: ObservableObject {
    @Injected(Container.remoteConfigService) private var remoteConfigService
    @Injected(Container.appStatsService) private var appStatsService
    let completion: () -> Void

    init(completion: @escaping () -> Void) {
        self.completion = completion
        load()
    }

    func load() {
        Task {
            await TimeoutOperationActor().operationWith(timeout: 2) { [weak self] in
                await self?.fetchRemoteConfig()
            }

            await MainActor.run {
                completion()
            }
        }
    }

    private func fetchRemoteConfig() async {
        do {
            try await remoteConfigService.fetchAndActivate()
            let appConfig = remoteConfigService.feature(AppConfig.self, by: "app_config")
            appStatsService.setShowsRI(to: appConfig?.should_sri ?? false)
            appStatsService.setLifetimeActivationAvailability(to: appConfig?.is_lifetime_activation_available ?? false)
            appStatsService.offering = appConfig?.paywall ?? QonversionOffering.paywall11.rawValue
            print("sdfsdf")
        } catch {
            print(error.localizedDescription)
        }
    }
}
