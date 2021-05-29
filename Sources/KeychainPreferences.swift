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
open class KeychainPreferences: PreferencesAdapter {

    // MARK: constantes

    /// Shared instance. service is equal to bundle identifier.
    public static var sharedInstance = KeychainPreferences(service: Bundle.main.bundleIdentifier ?? "Prephirences")

    /// Class Constants
    static let klass = String(kSecClass)

    /// Search Constants
    struct Match {
        static let policy = String(kSecMatchPolicy)
        static let itemList = String(kSecMatchItemList)
        static let searchList = String(kSecMatchSearchList)
        static let issuers = String(kSecMatchIssuers)
        static let emailAddressIfPresent = String(kSecMatchEmailAddressIfPresent)
        static let subjectContains = String(kSecMatchSubjectContains)
        static let caseInsensitive = String(kSecMatchCaseInsensitive)
        static let trustedOnly = String(kSecMatchTrustedOnly)
        static let limit = String(kSecMatchLimit)

        struct Limit {
            static let one = kSecMatchLimitOne
            static let all = kSecMatchLimitAll
        }
    }

    /// Value Key Constants
    struct Value {
        static let data = String(kSecValueData)
        static let ref = String(kSecValueRef)
        static let persistentRef = String(kSecValuePersistentRef)
    }

    /// Attribute Key Constants
    public struct Attribute {
        static let account = String(kSecAttrAccount)
        static let accessible = String(kSecAttrAccessible)
        static let accessGroup = String(kSecAttrAccessGroup)
        static let service  = String(kSecAttrService)
        static let description = String(kSecAttrDescription)
        static let comment = String(kSecAttrComment)
        static let generic = String(kSecAttrGeneric)
        static let creator = String(kSecAttrCreator)
        static let type = String(kSecAttrType)
        static let label = String(kSecAttrLabel)
        static let isInvisible = String(kSecAttrIsInvisible)
        static let isNegative = String(kSecAttrIsNegative)
        static let securityDomain = String(kSecAttrSecurityDomain)
        static let server = String(kSecAttrServer)
        static let `protocol` = String(kSecAttrProtocol)
        static let authenticationType = String(kSecAttrAuthenticationType)
        static let port = String(kSecAttrPort)
        static let path = String(kSecAttrPath)
        static let synchronizable = String(kSecAttrSynchronizable)
        static let creationDate = String(kSecAttrCreationDate)
        static let modificationDate = String(kSecAttrModificationDate)
        static let accessControl = String(kSecAttrAccessControl)
        @available(iOS 10.0, OSX 10.12, tvOS 10.0, *)
        static let tokenIDSecureEnclave = String(kSecAttrTokenIDSecureEnclave)
        @available(iOS 10.0, OSX 10.12, tvOS 10.0, *)
        static let accessGroupToken = String(kSecAttrAccessGroupToken)

        fileprivate let attributes: [String: Any]

        init(attributes: [String: Any]) {
            self.attributes = attributes
        }
    }

    /// Return Type Key Constants
    struct Return {
        static let attributes = String(kSecReturnAttributes)
        static let ref = String(kSecReturnRef)
        static let data = String(kSecReturnData)
        static let persistentRef = String(kSecReturnPersistentRef)
    }

    @available(iOS 9.0, OSX 10.11, *)
    @available(watchOS, unavailable)
    struct Use {
        struct Authentication {
            static let context = String(kSecUseAuthenticationContext)
            static let ui = String(kSecUseAuthenticationUI)

            // swiftlint:disable:next type_name
            struct UI {
                static let allow = String(kSecUseAuthenticationUIAllow)
                static let fail = String(kSecUseAuthenticationUIFail)
                static let skip = String(kSecUseAuthenticationUISkip)
            }
        }

        struct Operation {
            static let prompt = String(kSecUseOperationPrompt)
        }
    }

    #if os(iOS)
    static let SharedPassword = String(kSecSharedPassword)
    #endif

    // MARK: init

    /// Initialize generic password.
    public init(service: String) {
        self.klass = .genericPassword
        self.service = service

        self.protocol = nil
        self.authentication = nil
        self.server = nil
    }

    /// TODO Initialize internet password.
    init(server: URL, `protocol`: SecurityAttributeProtocol, authentication: SecurityAttributeAuthentication) {
        self.klass = .internetPassword
        self.server = server
        self.protocol = `protocol`
        self.authentication = authentication

        self.service = nil
    }

    // MARK: attributes

    /// Accesibility, by default `accessibleWhenUnlocked`
    open var accessible: SecurityAttributeAccessible = SecurityAttributeAccessible.defaultOption
    /// Type of data stored.
    open var klass: SecurityClass
    /// Optional access group
    open var accessGroup: String?

    /// Optional service (for .genericPassword)
    public let service: String?

    /// Optional server url (for .internetPassword)
    public let server: URL?
    /// Optional protocol (for .internetPassword)
    public let `protocol`: SecurityAttributeProtocol?
    /// Optional authentication (for .internetPassword)
    public let authentication: SecurityAttributeAuthentication?

    /// An optional message to display when authenticate
    open var authenticationPrompt: String?
    /// LAContext from framework LocalAuthentication
    open var authenticationContext: AnyObject?

    /// encoding used to convert string to data
    open var stringEncoding: String.Encoding = .utf8

    /// attribute to get last error
    open var lastStatus: OSStatus?

    // MARK: Functions

    func newQuery() -> [String: Any] {
        var query: [String: Any] = [KeychainPreferences.klass: klass.rawValue]
        query[Attribute.synchronizable] = kSecAttrSynchronizableAny

        switch klass {
        case .genericPassword:
            if let service = self.service {
                query[Attribute.service] = service
            }
            #if (!arch(i386) && !arch(x86_64)) || (!os(iOS) && !os(watchOS) && !os(tvOS)) // only for mac or real device (ie. not simulator)
            if let accessGroup = self.accessGroup {
                query[Attribute.accessGroup] = accessGroup
            }
            #endif
        case .internetPassword:
            if let server = server {
                query[Attribute.server] = server.host
                query[Attribute.port] = server.port
            }
            if let `protocol` = self.protocol {
                query[Attribute.protocol] = `protocol`.rawValue
            }
            if let authentication = self.authentication {
                query[Attribute.authenticationType] = authentication.rawValue
            }
        default:
            // not implemented
            fatalError("Not implemented \(klass)")
        }

        #if !os(watchOS)
        if #available(iOS 9.0, OSX 10.11, *) {
            if authenticationContext != nil {
                query[Use.Authentication.context] = authenticationContext
            }
        }

        if #available(OSX 10.10, *) {
            if authenticationPrompt != nil {
                query[Use.Operation.prompt] = authenticationPrompt
            }
        }
        #endif

        return query
    }

    @discardableResult
    func add(query: [String: Any]) -> Bool {
        SecItemDelete(query as CFDictionary) // XXX maybe let caller to a "has" before calling delete and make an update
        let status = SecItemAdd(query as CFDictionary, nil)
        lastStatus = status
        return status == errSecSuccess
    }

    @discardableResult
    func delete(query: [String: Any]) -> Bool {
        let status = SecItemDelete(query as CFDictionary)
        lastStatus = status
        return status == errSecSuccess
    }

    @discardableResult
    func update(query: [String: Any], attributes: [String: Any]) -> Bool {
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        lastStatus = status
        return status == errSecSuccess
    }

    public func attribute(forKey key: String) -> Attribute? {
        var query: [String: Any] = newQuery()
        query[Attribute.account] = key
        query[Return.attributes] = kCFBooleanTrue
        query[Return.data] = kCFBooleanTrue
        query[Return.persistentRef] = kCFBooleanTrue
        query[Return.ref] = kCFBooleanTrue
        query[Match.limit] = Match.Limit.one

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        lastStatus = status
        if status == errSecSuccess {
            if let attributes = result as? [String: Any] {
                return Attribute(attributes: attributes)
            }
        }
        return nil
    }

    #if os(iOS)
    /// See SecCreateSharedWebCredentialPassword
    @available(iOS 8.0, *)
    public class func generatePassword() -> String {
        return SecCreateSharedWebCredentialPassword()! as String
    }
    #endif
}

// MARK: Prephirences
extension KeychainPreferences: MutablePreferencesType {

    open subscript(key: PreferenceKey) -> PreferenceObject? {
        get {
            return self.object(forKey: key)
        }
        set {
            self.set(newValue, forKey: key)
        }
    }

    open func string(forKey key: PreferenceKey) -> String? {
        if let data = data(forKey: key), let currentString = String(data: data, encoding: stringEncoding) {
            return currentString
        }
        return nil
    }

    open func object(forKey key: PreferenceKey) -> PreferenceObject? {
        // XXX not able to know if must decoded or not here...
        if let object = unarchiveObject(forKey: key) {
            return object
        }
        if let data = data(forKey: key) {
            return data
        }
        return nil
    }

    open func data(forKey key: PreferenceKey) -> Data? {
        var query: [String: Any] = newQuery()
        query[Attribute.account] = key
        query[Return.data] = kCFBooleanTrue
        query[Match.limit] = Match.Limit.one

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        lastStatus = status
        if status == errSecSuccess {
            return result as? Data
        }
        return nil
    }

    open func keys() -> [String] {
        var query: [String: Any] = newQuery()
        query[Return.attributes] = kCFBooleanTrue
        query[Match.limit] = Match.Limit.all

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        lastStatus = status
        if status == errSecSuccess {
             if let items = result as? [[String: Any]] {
                return items.compactMap { $0[Attribute.account] as? String }
            }
        }
        return []
    }

    open func dictionary() -> PreferencesDictionary {
        var query: [String: Any] = newQuery()
        query[Return.attributes] = kCFBooleanTrue
        #if os(iOS) || os(watchOS) || os(tvOS)
        query[Return.data] = kCFBooleanTrue
        #endif
        query[Match.limit] = Match.Limit.all

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        var dico = PreferencesDictionary()
        lastStatus = status
        if status == errSecSuccess {
            if let items = result as? [[String: Any]] {
                for item in items {
                    if let key = item[Attribute.account] as? String {
                        #if os(iOS) || os(watchOS) || os(tvOS)
                        if let data = item[Value.data] as? Data {
                            // XXX maybe do not convert anything, we cannot asume the type of data...
                           /* if let text = String(data: data, encoding: stringEncoding) {
                                dico[key] = text
                            } else {*/
                            dico[key] = data
                            /*}*/
                        } else {
                            dico[key] = nil
                        }
                        #else
                        // macOS seems to not be able to get all items with data
                        dico[key] = data(forKey: key)
                        #endif
                    }
                }
            }
        }
        return dico
    }

    open func set(_ value: PreferenceObject?, forKey key: PreferenceKey) {
        if let string = value as? String {
            if let data = string.data(using: stringEncoding) {
                set(data, forKey: key)
            }
        } else if let data = value as? Data {
            var query: [String: Any] = newQuery()
            query[Attribute.account] = key
            query[Value.data] = data
            query[Attribute.accessible] = accessible.rawValue

            add(query: query)
        } else if let objectToArchive = value {
            set(objectToArchive: objectToArchive, forKey: key)
        } else {
            removeObject(forKey: key)
        }
    }
    open func removeObject(forKey key: PreferenceKey) {
        var query: [String: Any] = newQuery()
        query[Attribute.account] = key
        delete(query: query)
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

    open func hasObject(forKey key: PreferenceKey) -> Bool {
        var query: [String: Any] = newQuery()
        query[Attribute.account] = key

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        lastStatus = status
        switch status {
        case errSecSuccess:
            return true
        case errSecItemNotFound:
            return false
        default:
            return false
        }
    }

    open func clearAll() {
        var query: [String: Any] = newQuery()
        #if !os(iOS) && !os(watchOS) && !os(tvOS)
        query[Match.limit] = Match.Limit.all
        #endif
        delete(query: query)
    }

    open func set(dictionary: PreferencesDictionary) {
        for (key, value) in dictionary {
            set(value, forKey: key)
        }
    }

    // MARK: addon to cast on string or data
    open subscript(string key: PreferenceKey) -> String? {
        get {
            return string(forKey: key)
        }
        set {
            if let value = newValue {
                set(value, forKey: key)
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
                set(value, forKey: key)
            } else {
                removeObject(forKey: key)
            }
        }
    }

    open subscript(attribute key: PreferenceKey) -> Attribute? {
        return attribute(forKey: key)
    }

}

// MARK: kSecAttrAccessible
public enum SecurityAttributeAccessible: CustomStringConvertible {
    case whenUnlocked, whenUnlockedThisDeviceOnly, afterFirstUnlock
    case afterFirstUnlockThisDeviceOnly, always, whenPasscodeSetThisDeviceOnly, alwaysThisDeviceOnly

    public static var defaultOption: SecurityAttributeAccessible {  return .whenUnlocked }

    public var rawValue: String {
        switch self {
        case .whenUnlocked:
            return String(kSecAttrAccessibleWhenUnlocked)
        case .whenUnlockedThisDeviceOnly:
            return String(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
        case .afterFirstUnlock:
            return String(kSecAttrAccessibleAfterFirstUnlock)
        case .afterFirstUnlockThisDeviceOnly:
            return String(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
        case .always:
            return String(kSecAttrAccessibleAlways)
        case .alwaysThisDeviceOnly:
            return String(kSecAttrAccessibleAlwaysThisDeviceOnly)
        case .whenPasscodeSetThisDeviceOnly:
            #if os(iOS) || os(watchOS) || os(tvOS)
                return String(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
            #elseif os(OSX)
                if #available(OSX 10.10, *) {
                    return String(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
                }
                return ""
            #endif
        }

    }

    public var description: String { return rawValue }
}

// MARK: kSecClass
public enum SecurityClass: CustomStringConvertible {
    case genericPassword, internetPassword, certificate, key, identity

    public static var defaultOption: SecurityClass {  return .genericPassword }

    public var rawValue: String {
        switch self {
        case .genericPassword:
            return String(kSecClassGenericPassword)
        case .internetPassword:
            return String(kSecClassInternetPassword)
        case .certificate:
            return String(kSecClassCertificate)
        case .key:
            return String(kSecClassKey)
        case .identity:
            return String(kSecClassIdentity)
        }
    }
    public var description: String { return rawValue }
}

// MARK: kSecAttrAuthentication
public enum SecurityAttributeAuthentication: CustomStringConvertible {
    case httpBasic, httpDigest, htmlForm, ntlm, msn, dpa, rpa, `default`

    public var rawValue: String {
        switch self {
        case .ntlm:
            return String(kSecAttrAuthenticationTypeNTLM)
        case .msn:
            return String(kSecAttrAuthenticationTypeMSN)
        case .dpa:
            return String(kSecAttrAuthenticationTypeDPA)
        case .rpa:
            return String(kSecAttrAuthenticationTypeRPA)
        case .httpBasic:
            return String(kSecAttrAuthenticationTypeHTTPBasic)
        case .httpDigest:
            return String(kSecAttrAuthenticationTypeHTTPDigest)
        case .htmlForm:
            return String(kSecAttrAuthenticationTypeHTMLForm)
        case .`default`:
            return String(kSecAttrAuthenticationTypeDefault)
        }
    }

    public var description: String { return rawValue }

}

// MARK: kSecAttrProtocol
public enum SecurityAttributeProtocol {
    case ftp, ftps, ftpAccount, ftpProxy, http, https, httpProxy, httpsProxy, irc, nntp
    case pop3, smtp, socks, imap, ldap, appleTalk, afp, telnet, ssh, smb
    case rtsp, rtspProxy, daap, eppc, ipp, nntps, ldaps, telnetS, imaps, ircs, pop3S

    public var rawValue: String {
        switch self {
        case .ftp:
            return String(kSecAttrProtocolFTP)
        case .ftpProxy:
            return String(kSecAttrProtocolFTPProxy)
        case .ftpAccount:
            return String(kSecAttrProtocolFTPAccount)
        case .ftps:
            return String(kSecAttrProtocolFTPS)
        case .http:
            return String(kSecAttrProtocolHTTP)
        case .https:
            return String(kSecAttrProtocolHTTPS)
        case .httpProxy:
            return String(kSecAttrProtocolHTTPProxy)
        case .httpsProxy:
            return String(kSecAttrProtocolHTTPSProxy)
        case .irc:
            return String(kSecAttrProtocolIRC)
        case .nntp:
            return String(kSecAttrProtocolNNTP)
        case .pop3:
            return String(kSecAttrProtocolPOP3)
        case .smtp:
            return String(kSecAttrProtocolSMTP)
        case .socks:
            return String(kSecAttrProtocolSOCKS)
        case .imap:
            return String(kSecAttrProtocolIMAP)
        case .ldap:
            return String(kSecAttrProtocolLDAP)
        case .appleTalk:
            return String(kSecAttrProtocolAppleTalk)
        case .afp:
            return String(kSecAttrProtocolAFP)
        case .telnet:
            return String(kSecAttrProtocolTelnet)
        case .ssh:
            return String(kSecAttrProtocolSSH)
        case .smb:
            return String(kSecAttrProtocolSMB)
        case .rtsp:
            return String(kSecAttrProtocolRTSP)
        case .rtspProxy:
            return String(kSecAttrProtocolRTSPProxy)
        case .daap:
            return String(kSecAttrProtocolDAAP)
        case .eppc:
            return String(kSecAttrProtocolEPPC)
        case .ipp:
            return String(kSecAttrProtocolIPP)
        case .nntps:
            return String(kSecAttrProtocolNNTPS)
        case .ldaps:
            return String(kSecAttrProtocolLDAPS)
        case .telnetS:
            return String(kSecAttrProtocolTelnetS)
        case .imaps:
            return String(kSecAttrProtocolIMAPS)
        case .ircs:
            return String(kSecAttrProtocolIRCS)
        case .pop3S:
            return String(kSecAttrProtocolPOP3S)
        }
    }

    public var description: String { return rawValue }

}

// MARK: Attribute
extension KeychainPreferences.Attribute {

    public subscript(key: String) -> Any? {
        return attributes[key]
    }

    public var klass: String? {
        return attributes[KeychainPreferences.klass] as? String
    }

    // values
    public var data: Data? {
        return attributes[KeychainPreferences.Value.data] as? Data
    }
    public var ref: Data? {
        return attributes[KeychainPreferences.Value.ref] as? Data
    }
    public var persistentRef: Data? {
        return attributes[KeychainPreferences.Value.persistentRef] as? Data
    }

    // attributes
    public var account: String? {
        return attributes[KeychainPreferences.Attribute.account] as? String
    }
    public var service: String? {
        return attributes[KeychainPreferences.Attribute.service] as? String
    }
    public var accessGroup: String? {
        return attributes[KeychainPreferences.Attribute.accessGroup] as? String
    }
    public var accessible: String? {
        return attributes[KeychainPreferences.Attribute.accessible] as? String
    }
    public var synchronizable: Bool? {
        return attributes[KeychainPreferences.Attribute.synchronizable] as? Bool
    }
    public var creationDate: Date? {
        return attributes[KeychainPreferences.Attribute.creationDate] as? Date
    }
    public var modificationDate: Date? {
        return attributes[KeychainPreferences.Attribute.modificationDate] as? Date
    }
    public var comment: String? {
        return attributes[KeychainPreferences.Attribute.comment] as? String
    }
    public var attributeDescription: String? {
        return attributes[KeychainPreferences.Attribute.description] as? String
    }
    public var creator: String? {
        return attributes[KeychainPreferences.Attribute.creator] as? String
    }
    public var type: String? {
        return attributes[KeychainPreferences.Attribute.type] as? String
    }
    public var label: String? {
        return attributes[KeychainPreferences.Attribute.label] as? String
    }
    public var isInvisible: Bool? {
        return attributes[KeychainPreferences.Attribute.isInvisible] as? Bool
    }
    public var isNegative: Bool? {
        return attributes[KeychainPreferences.Attribute.isNegative] as? Bool
    }
    public var generic: Data? {
        return attributes[KeychainPreferences.Attribute.generic] as? Data
    }
    public var securityDomain: String? {
        return attributes[KeychainPreferences.Attribute.securityDomain] as? String
    }
    public var server: String? {
        return attributes[KeychainPreferences.Attribute.server] as? String
    }
    public var `protocol`: String? {
        return attributes[KeychainPreferences.Attribute.protocol] as? String
    }
    public var authenticationType: String? {
        return attributes[KeychainPreferences.Attribute.authenticationType] as? String
    }
    public var port: Int? {
        return attributes[KeychainPreferences.Attribute.port] as? Int
    }
    public var path: String? {
        return attributes[KeychainPreferences.Attribute.path] as? String
    }
    public var accessControl: SecAccessControl? {
        if #available(OSX 10.10, *) {
            if let accessControl = attributes[KeychainPreferences.Attribute.accessControl] {
                // swiftlint:disable:next force_cast
                return (accessControl as! SecAccessControl)
            }
            return nil
        }
        return nil
    }
}

// MARK: property wrapper

@propertyWrapper
public class KeychainPreference<T>: MutablePreference<T> {

    public init(keychain: KeychainPreferences = .sharedInstance,
                key: PreferenceKey,
                transformation: PreferenceTransformation = TransformationKey.none) {
        super.init(preferences: keychain, key: key, transformation: transformation)
    }

    /// property wrapper value
    override open var wrappedValue: T? {
        get {
            return value
        }
        set {
            value = newValue
        }
    }

}
