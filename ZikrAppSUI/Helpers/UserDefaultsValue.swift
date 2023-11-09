//
//  UserDefaultsValue.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 16.08.2023.
//

import Foundation

@propertyWrapper
public struct UserDefaultsValue<Value> {
    public let key: String
    public let defaultValue: Value
    public var container: UserDefaults = .standard

    public init(key: String, defaultValue: Value, container: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.container = container
    }

    public var wrappedValue: Value {
        get {
            return self.container.object(forKey: key) as? Value ?? self.defaultValue
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                container.removeObject(forKey: key)
            } else {
                container.set(newValue, forKey: key)
            }
        }
    }
}

extension UserDefaultsValue where Value: ExpressibleByNilLiteral {
    public init(key: String, container: UserDefaults = .standard) {
        self.init(key: key, defaultValue: nil, container: container)
    }
}

// Added to support optional values in UserDefaultsValue property wrapper
protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    public var isNil: Bool { self == nil }
}
