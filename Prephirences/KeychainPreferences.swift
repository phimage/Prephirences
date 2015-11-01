//
//  KeychainPreferences.swift
//  Prephirences
/*
The MIT License (MIT)

Copyright (c) 2015 Eric Marchand (phimage)

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
public class KeychainPreferences: PreferencesAdapter, MutablePreferencesType {

    public class var sharedInstance : KeychainPreferences {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KeychainPreferences?
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = KeychainPreferences(service: NSBundle.mainBundle().bundleIdentifier ?? "Prephirences")
        }
        return Static.instance!
    }

    private struct Constants {
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
    public var accessible: SecurityAttributeAccessible = SecurityAttributeAccessible.defaultOption
    public var klass: SecurityClass = SecurityClass.defaultOption
    public var accessGroup: String?
    public var service: String?

    public var lastStatus: OSStatus?
    
    // MARK: Prephirences
    public subscript(key: String) -> AnyObject? {
        get {
            return self.objectForKey(key)
        }
        set {
            self.setObject(newValue, forKey: key)
        }
    }

    public func stringForKey(key: String) -> String? {
        if let data = dataForKey(key), currentString = NSString(data: data, encoding: NSUTF8StringEncoding) as? String {
            return currentString
        }
        return nil
    }
    
    public func objectForKey(key: String) -> AnyObject? {
        // XXX not able to know if must decoded or not here...
        if let object: AnyObject = unarchiveObjectForKey(key){
            return object
        }
        return nil
    }

    public func dataForKey(key: String) -> NSData? {
        var query: [String: AnyObject] = [
            Constants.klass       : klass.rawValue,
            Constants.account     : key,
            Constants.returnData  : kCFBooleanTrue,
            Constants.matchLimit  : kSecMatchLimitOne ]
        if let accessGroup = self.accessGroup {
            query[Constants.accessGroup] = accessGroup
        }
        if let service = self.service {
            query[Constants.service] = service
        }
    
        var result: AnyObject?
        
        let status = withUnsafeMutablePointer(&result) {
            SecItemCopyMatching(query as CFDictionaryRef, UnsafeMutablePointer($0))
        }
        
        if status == errSecSuccess {
            return result as? NSData
        }
        return nil
    }
    
    public func keys() -> [String] {
        var query: [String: AnyObject] = [
            Constants.klass       : klass.rawValue,
            Constants.returnData  : kCFBooleanTrue,
            Constants.matchLimit  : kSecMatchLimitAll ]
        if let accessGroup = self.accessGroup {
            query[Constants.accessGroup] = accessGroup
        }
        if let service = self.service {
            query[Constants.service] = service
        }
        
        var result: AnyObject?
        
        let status = withUnsafeMutablePointer(&result) {
            SecItemCopyMatching(query as CFDictionaryRef, UnsafeMutablePointer($0))
        }

        lastStatus = status
        if status == errSecSuccess {
             if let items = result as? [[String: AnyObject]] {
                return items.map {
                    return $0[Constants.account] as? String ?? "KeychainPreferencesExclude"
                    }.filter{return $0 != "KeychainPreferencesExclude"}
            }
        }
        return []
    }
    
    public func dictionary() -> [String : AnyObject] {
        var query: [String: AnyObject] = [
            Constants.klass       : klass.rawValue,
            Constants.returnData  : kCFBooleanTrue, //  #if os(iOS) ?
            Constants.returnAttributes : kCFBooleanTrue,
            Constants.matchLimit  : kSecMatchLimitAll ]
        if let accessGroup = self.accessGroup {
            query[Constants.accessGroup] = accessGroup
        }
        if let service = self.service {
            query[Constants.service] = service
        }

        var result: AnyObject?
        let status = withUnsafeMutablePointer(&result) {
            SecItemCopyMatching(query as CFDictionaryRef, UnsafeMutablePointer($0))
        }
        
        var dico = [String : AnyObject]()
        lastStatus = status
        if status == errSecSuccess {
            if let items = result as? [[String: AnyObject]] {
                for item in items {
                    if let key = item[Constants.account] as? String, data = item[Constants.valueData] as? NSData {
                        if let text = NSString(data: data, encoding: NSUTF8StringEncoding) as? String {
                            dico[key] = text
                        } else  {
                            dico[key] = data
                        }
                    }
                }
            }
        }
        return dico
    }

    public func setObject(value: AnyObject?, forKey key: String){
        if let string = value as? String {
            if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
                setObject(data, forKey: key)
            }
        }
        else if let data = value as? NSData {
            var query: [String: AnyObject] = [
                Constants.klass       : klass.rawValue,
                Constants.account : key,
                Constants.valueData   : data,
                Constants.accessible  : accessible.rawValue
            ]
            if let accessGroup = self.accessGroup {
                query[Constants.accessGroup] = accessGroup
            }
            if let service = self.service {
                query[Constants.service] = service
            }
            SecItemDelete(query as CFDictionaryRef)
            lastStatus =  SecItemAdd(query as CFDictionaryRef, nil)
            // return status == errSecSuccess
        }
        else if let objectToArchive: AnyObject = value {
            setObjectToArchive(objectToArchive, forKey: key)
        }
        else {
            removeObjectForKey(key)
        }
    }
    public func removeObjectForKey(key: String){
        var query: [String: AnyObject] = [
            Constants.klass       : klass.rawValue,
            Constants.account : key ]
        if let accessGroup = self.accessGroup {
            query[Constants.accessGroup] = accessGroup
        }
        if let service = self.service {
            query[Constants.service] = service
        }

        lastStatus = SecItemDelete(query as CFDictionaryRef)
        // return status == errSecSuccess
    }
    public func setInteger(value: Int, forKey key: String){
        self.setObject(NSNumber(integer: value), forKey: key)
    }
    public func setFloat(value: Float, forKey key: String){
        self.setObject(NSNumber(float: value), forKey: key)
    }
    public func setDouble(value: Double, forKey key: String){
        self.setObject(NSNumber(double: value), forKey: key)
    }
    public func setBool(value: Bool, forKey key: String){
        self.setObject(NSNumber(bool: value), forKey: key)
    }
    public func setURL(url: NSURL?, forKey key: String){
        self.setObject(url, forKey: key)
    }
    public func setObjectToArchive(value: AnyObject?, forKey key: String) {
        Prephirences.archiveObject(value, preferences: self, forKey: key)
    }
    public func clearAll(){
        var query = [ kSecClass as String : klass.rawValue ]
        if let accessGroup = self.accessGroup {
            query[Constants.accessGroup] = accessGroup
        }
        if let service = self.service {
            query[Constants.service] = service
        }
        
        lastStatus = SecItemDelete(query as CFDictionaryRef)
    }

    public func setObjectsForKeysWithDictionary(dictionary: [String : AnyObject]){
        for (key,value) in dictionary {
            setObject(value, forKey: key )
        }
    }
    
    // MARK: addon to cast on string or data
    public subscript(string key: String) -> String? {
        get {
            return stringForKey(key)
        }
        set {
            if let value = newValue {
                setObject(value, forKey: key)
            } else {
                removeObjectForKey(key)
            }
        }
    }

    public subscript(data key: String) -> NSData? {
        get {
            return dataForKey(key)
        }
        set {
            if let value = newValue {
                setObject(value, forKey: key)
            } else {
                removeObjectForKey(key)
            }
        }
    }
 
}

// MARK: kSecAttrAccessible
public enum SecurityAttributeAccessible: CustomStringConvertible {
    case AccessibleWhenUnlocked, AccessibleWhenUnlockedThisDeviceOnly,  AccessibleAfterFirstUnlock, AccessibleAfterFirstUnlockThisDeviceOnly, AccessibleAlways,  AccessibleWhenPasscodeSetThisDeviceOnly,  AccessibleAlwaysThisDeviceOnly
    
    public static var defaultOption: SecurityAttributeAccessible {  return .AccessibleWhenUnlocked }
    
    public var rawValue: String {
        switch self {
        case .AccessibleWhenUnlocked:
            return toString(kSecAttrAccessibleWhenUnlocked)
        case .AccessibleWhenUnlockedThisDeviceOnly:
            return toString(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
        case .AccessibleAfterFirstUnlock:
            return toString(kSecAttrAccessibleAfterFirstUnlock)
        case .AccessibleAfterFirstUnlockThisDeviceOnly:
            return toString(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
        case .AccessibleAlways:
            return toString(kSecAttrAccessibleAlways)
        case .AccessibleAlwaysThisDeviceOnly:
            return toString(kSecAttrAccessibleAlwaysThisDeviceOnly)
        case .AccessibleWhenPasscodeSetThisDeviceOnly:
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
    case GenericPassword /*, InternetPassword, Certificate, Key, Identity*/
    
    public static var defaultOption: SecurityClass {  return .GenericPassword }
    
    public var rawValue: String {
        switch self {
        case .GenericPassword:
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
private func toString(value: CFStringRef) -> String {
    return (value as String) ?? ""
}
