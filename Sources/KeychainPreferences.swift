//
//  KeychainPreferences.swift
//  Prephirences
/*
The MIT License (MIT)

Copyright (c) 2017 Eric Marchand (phimage)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import Foundation
import Security

/* Store into keychain
 * Store only data, string, dictionnary of this type
 * All other types are archived into data
 */
open class KeychainPreferences: PreferencesAdapter, MutablePreferencesType {

    open static var sharedInstance = KeychainPreferences(service: Bundle.main.bundleIdentifier ?? "Prephirences")

    fileprivate struct Constants {
        static var klass: String { return toString(kSecClass) }
        static var account: String { return toString(kSecAttrAccount) }
        static var valueData: String { return toString(kSecValueData) }
        static var returnData: String { return toString(kSecReturnData) }
        static var matchLimit: String { return toString(kSecMatchLimit) }
        static var accessible: String { return toString(kSecAttrAccessible) }
        static var accessGroup: String { return toString(kSecAttrAccessGroup) }
        static var service: String { return toString(kSecAttrService) }
        static var returnAttributes: String { return toString(kSecReturnAttributes) }
    }

    public init(service: String) {
        self.service = service
    }

    // MARK: attributes
    open var accessible: SecurityAttributeAccessible = SecurityAttributeAccessible.defaultOption
    open var klass: SecurityClass = SecurityClass.defaultOption
    open var accessGroup: String?
    open var service: String?

    open var lastStatus: OSStatus?

    // MARK: Prephirences
    open subscript(key: PreferenceKey) -> PreferenceObject? {
        get {
            return self.object(forKey: key)
        }
        set {
            self.set(newValue, forKey: key)
        }
    }

    open func string(forKey key: PreferenceKey) -> String? {
        if let data = data(forKey: key), let currentString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String {
            return currentString
        }
        return nil
    }

    open func object(forKey key: PreferenceKey) -> PreferenceObject? {
        // XXX not able to know if must decoded or not here...
        if let object = unarchiveObject(forKey: key) {
            return object
        }
        return nil
    }

    open func data(forKey key: PreferenceKey) -> Data? {
        var query: [String: Any] = [
            Constants.klass: klass.rawValue as AnyObject,
            Constants.account: key as AnyObject,
            Constants.returnData: kCFBooleanTrue,
            Constants.matchLimit: kSecMatchLimitOne ]
        if let accessGroup = self.accessGroup {
            query[Constants.accessGroup] = accessGroup
        }
        if let service = self.service {
            query[Constants.service] = service
        }

        var result: AnyObject?

        let status = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        if status == errSecSuccess {
            return result as? Data
        }
        return nil
    }

    open func keys() -> [String] {
        var query: [String: Any] = [
            Constants.klass: klass.rawValue as AnyObject,
            Constants.returnData: kCFBooleanTrue,
            Constants.matchLimit: kSecMatchLimitAll ]
        if let accessGroup = self.accessGroup {
            query[Constants.accessGroup] = accessGroup
        }
        if let service = self.service {
            query[Constants.service] = service
        }

        var result: AnyObject?

        let status = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        lastStatus = status
        if status == errSecSuccess {
             if let items = result as? [[String: AnyObject]] {
                return items.map {
                    return $0[Constants.account] as? String ?? "KeychainPreferencesExclude"
                    }.filter { return $0 != "KeychainPreferencesExclude" }
            }
        }
        return []
    }

    open func dictionary() -> PreferencesDictionary {
        var query: [String: Any] = [
            Constants.klass: klass.rawValue as AnyObject,
            Constants.returnData: kCFBooleanTrue, //  #if os(iOS) ?
            Constants.returnAttributes: kCFBooleanTrue,
            Constants.matchLimit: kSecMatchLimitAll ]
        if let accessGroup = self.accessGroup {
            query[Constants.accessGroup] = accessGroup
        }
        if let service = self.service {
            query[Constants.service] = service
        }

        var result: AnyObject?
        let status = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        var dico = PreferencesDictionary()
        lastStatus = status
        if status == errSecSuccess {
            if let items = result as? [[String: AnyObject]] {
                for item in items {
                    if let key = item[Constants.account] as? String, let data = item[Constants.valueData] as? Data {
                        if let text = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String {
                            dico[key] = text
                        } else {
                            dico[key] = data
                        }
                    }
                }
            }
        }
        return dico
    }

    open func set(_ value: PreferenceObject?, forKey key: PreferenceKey) {
        if let string = value as? String {
            if let data = string.data(using: String.Encoding.utf8) {
                set(data as AnyObject?, forKey: key)
            }
        } else if let data = value as? Data {
            var query: [String: Any] = [
                Constants.klass: klass.rawValue as AnyObject,
                Constants.account: key as AnyObject,
                Constants.valueData: data as AnyObject,
                Constants.accessible: accessible.rawValue as AnyObject
            ]
            if let accessGroup = self.accessGroup {
                query[Constants.accessGroup] = accessGroup
            }
            if let service = self.service {
                query[Constants.service] = service
            }
            SecItemDelete(query as CFDictionary)
            lastStatus =  SecItemAdd(query as CFDictionary, nil)
            // return status == errSecSuccess
        } else if let objectToArchive = value {
            set(objectToArchive: objectToArchive, forKey: key)
        } else {
            removeObject(forKey: key)
        }
    }
    open func removeObject(forKey key: PreferenceKey) {
        var query: [String: Any] = [
            Constants.klass: klass.rawValue as AnyObject,
            Constants.account: key as AnyObject ]
        if let accessGroup = self.accessGroup {
            query[Constants.accessGroup] = accessGroup
        }
        if let service = self.service {
            query[Constants.service] = service
        }

        lastStatus = SecItemDelete(query as CFDictionary)
        // return status == errSecSuccess
    }
    open func set(_ value: Int, forKey key: PreferenceKey) {
        self.set(NSNumber(value: value), forKey: key)
    }
    open func set(_ value: Float, forKey key: PreferenceKey) {
        self.set(NSNumber(value: value), forKey: key)
    }
    open func set(_ value: Double, forKey key: PreferenceKey) {
        self.set(NSNumber(value: value), forKey: key)
    }
    open func set(_ value: Bool, forKey key: PreferenceKey) {
        self.set(NSNumber(value: value), forKey: key)
    }
    open func set(url value: URL?, forKey key: PreferenceKey) {
        self.set(value, forKey: key)
    }
    open func set(objectToArchive value: PreferenceObject?, forKey key: PreferenceKey) {
        Prephirences.archive(object: value, intoPreferences: self, forKey: key)
    }
    open func clearAll() {
        var query = [kSecClass as String: klass.rawValue]
        if let accessGroup = self.accessGroup {
            query[Constants.accessGroup] = accessGroup
        }
        if let service = self.service {
            query[Constants.service] = service
        }

        lastStatus = SecItemDelete(query as CFDictionary)
    }

    open func set(dictionary: PreferencesDictionary) {
        for (key, value) in dictionary {
            set(value, forKey: key )
        }
    }

    // MARK: addon to cast on string or data
    open subscript(string key: PreferenceKey) -> String? {
        get {
            return string(forKey: key)
        }
        set {
            if let value = newValue {
                set(value as AnyObject?, forKey: key)
            } else {
                removeObject(forKey: key)
            }
        }
    }

    open subscript(data key: PreferenceKey) -> Data? {
        get {
            return data(forKey: key)
        }
        set {
            if let value = newValue {
                set(value as AnyObject?, forKey: key)
            } else {
                removeObject(forKey: key)
            }
        }
    }

}

// MARK: kSecAttrAccessible
public enum SecurityAttributeAccessible: CustomStringConvertible {
    case accessibleWhenUnlocked, accessibleWhenUnlockedThisDeviceOnly, accessibleAfterFirstUnlock
    case accessibleAfterFirstUnlockThisDeviceOnly, accessibleAlways, accessibleWhenPasscodeSetThisDeviceOnly, accessibleAlwaysThisDeviceOnly

    public static var defaultOption: SecurityAttributeAccessible {  return .accessibleWhenUnlocked }

    public var rawValue: String {
        switch self {
        case .accessibleWhenUnlocked:
            return toString(kSecAttrAccessibleWhenUnlocked)
        case .accessibleWhenUnlockedThisDeviceOnly:
            return toString(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
        case .accessibleAfterFirstUnlock:
            return toString(kSecAttrAccessibleAfterFirstUnlock)
        case .accessibleAfterFirstUnlockThisDeviceOnly:
            return toString(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
        case .accessibleAlways:
            return toString(kSecAttrAccessibleAlways)
        case .accessibleAlwaysThisDeviceOnly:
            return toString(kSecAttrAccessibleAlwaysThisDeviceOnly)
        case .accessibleWhenPasscodeSetThisDeviceOnly:
            #if os(iOS) || os(watchOS) || os(tvOS)
                return toString(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
            #elseif os(OSX)
                if #available(OSX 10.10, *) {
                    return toString(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
                }
                return ""
            #endif
        }

    }

    public var description: String { return rawValue }
}

// MARK: kSecClass
public enum SecurityClass: CustomStringConvertible {
    case genericPassword /*, InternetPassword, Certificate, Key, Identity*/

    public static var defaultOption: SecurityClass {  return .genericPassword }

    public var rawValue: String {
        switch self {
        case .genericPassword:
            return toString(kSecClassGenericPassword)
       /* case .InternetPassword:
            return toString(kSecClassInternetPassword)
        case .Certificate:
            return toString(kSecClassCertificate)
        case .Key:
            return toString(kSecClassKey)
        case .Identity:
            return toString(kSecClassIdentity)
        }*/
        }
    }

    public var description: String { return rawValue }
}

// MARK: private
private func toString(_ value: CFString) -> String {
    return value as String
}
