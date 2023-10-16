//
//  RemoteConfigService.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 11.09.2023.
//

import FirebaseCore
import FirebaseRemoteConfig
import Factory

public protocol RemoteConfigService {
    func feature<T: Decodable>(_ type: T.Type, by id: String) -> T?

    func fetch() async throws
    func activate() async throws
    func fetchAndActivate() async throws
}

final class RemoteConfigServiceImpl: RemoteConfigService {
    lazy var remoteConfig: RemoteConfig = {

        let remoteConfig = RemoteConfig.remoteConfig()

        let settings = RemoteConfigSettings()
//        if AppConfiguration.current == .appStore {
//            settings.minimumFetchInterval = 1 * 60 * 60
//        } else {
            settings.minimumFetchInterval = 0
//        }
        remoteConfig.configSettings = settings
        return remoteConfig
    }()

    func feature<T>(_ type: T.Type, by id: String) -> T? where T : Decodable {
        let value = remoteConfig.configValue(forKey: id)
        guard
            let json = value.stringValue,
            let jsonData = json.data(using: .utf8)
        else {
            return nil
        }
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(type, from: jsonData)
        } catch {
            let invalidConfig = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
            return nil
        }
    }
    
    func fetch() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            self.remoteConfig.fetch { status, error -> Void in
                switch status {
                case .success:
                    continuation.resume(returning: ())
                case .throttled, .noFetchYet:
                    continuation.resume(returning: ())
                case .failure:
                    continuation.resume(throwing: RemoteConfigServiceError.configFetchError(underlying: error))
                }
            }
        }
    }
    
    func activate() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            self.remoteConfig.activate { _, error in
                guard error == nil else {
                    continuation.resume(throwing: RemoteConfigServiceError.configActivateError(underlying: error))
                    return
                }

                continuation.resume(returning: ())
            }
        }
    }
    
    func fetchAndActivate() async throws {
        try await self.remoteConfig.fetchAndActivate()
    }
    
    
}

public enum RemoteConfigServiceError: Error {
    case featureParsingError(invalidConfig: [String: Any]?, underlying: Error)
    case configFetchError(underlying: Error?)
    case configActivateError(underlying: Error?)
    
    var localizedDescription: String {
        switch self {
        case let .featureParsingError(invalidConfig, error):
            var description = "RemoteConfigServiceError.featureParsingError. Underlying: \(error.localizedDescription)"
            if let invalidConfig = invalidConfig {
                description += "Invalid config: \(invalidConfig)"
            }
            return description
        case let .configFetchError(error):
            var description = "RemoteConfigServiceError.configFetchError."
            if let error = error {
                description += " Underlying: \(error.localizedDescription)"
            }
            return description
        case let .configActivateError(error):
            var description = "RemoteConfigServiceError.configActivateError."
            if let error = error {
                description += " Underlying: \(error.localizedDescription)"
            }
            return description
        }
    }
}

protocol Feature: Decodable {
    static var featureId: String { get }
    static var featureDefaultValue: Self { get }

    var ab_group_name: String { get }
}

extension RemoteConfigService {
    func feature<T>(_ type: T.Type) -> T where T: Feature {
        feature(type, by: type.featureId) ?? type.featureDefaultValue
    }
}

public extension Container {
    static let remoteConfigService = Factory<RemoteConfigService>(scope: .singleton) {
        RemoteConfigServiceImpl()
    }
}
