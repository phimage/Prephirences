//
//  PrephirencesTests.swift
//  PrephirencesTests
//
//  Created by phimage on 05/06/15.
//  Copyright (c) 2017 phimage. All rights reserved.
//

import Foundation
import XCTest
@testable import Prephirences
#if os(iOS)
    import UIKit
typealias Color = UIColor
#endif
#if os(OSX)
    import AppKit
typealias Color = NSColor
#endif

class PrephirencesTests: XCTestCase {

    let mykey = "key"
    let myvalue = "value"
    let mykey2 = "key2"

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func printPreferences(_ preferences: PreferencesType) {
        for (key,value) in preferences.dictionary() {
            print("\(key)=\(value)")
        }
    }

    func printDictionaryPreferences(_ dictionaryPreferences: DictionaryPreferences) {
        printPreferences(dictionaryPreferences)
        for (key,value) in dictionaryPreferences {
            print("\(key)=\(value)")
        }
    }

    func testFromDictionary() {
        let preferences = DictionaryPreferences(dictionary: [mykey: myvalue, "key2": "value2"])
        printDictionaryPreferences(preferences)
    }

    func testFromDictionaryLiteral() {
        let preferences: DictionaryPreferences = [mykey: myvalue, "key2": "value2"]
        printDictionaryPreferences(preferences)
    }

    /*func testWriteDictionaryLiteral() {
        var preferences: DictionaryPreferences = [mykey: myvalue, "key2": "value2"]
        printDictionaryPreferences(preferences)

        preferences.writeToFile("/tmp/prephirence.test", atomically: true)

    }*/

    func testFromFile() {
        if let filePath = Bundle(for: type(of: self)).path(forResource: "Test", ofType: "plist") {
            if  let preference = DictionaryPreferences(filePath: filePath) {
                    for (key,value) in preference.dictionary() {
                        print("\(key)=\(value)")
                    }

            } else {
                XCTFail("Failed to read from file")
            }
        } else {
            XCTFail("Failed to get file url")
        }
        
        if let preference = DictionaryPreferences(filename: "Test", ofType: "plist", bundle: Bundle(for: type(of: self))) ??
            DictionaryPreferences(filePath: "Tests/Test.plist") {
            for (key,value) in preference.dictionary() {
                print("\(key)=\(value)")
            }
        } else {
            XCTFail("Failed to read from file using shortcut init")
        }
    }

    func testUserDefaults() {
        let userDefaults = Foundation.UserDefaults.standard
        printPreferences(userDefaults)



        userDefaults[mykey] = myvalue
        XCTAssert(userDefaults[mykey] as! String == myvalue, "not affected")
        userDefaults[mykey] = nil
        XCTAssert(userDefaults[mykey] as? String ?? nil == nil, "not nil affected") // return a proxyPreferences


        userDefaults.set(myvalue, forKey:mykey)
        XCTAssert(userDefaults.object(forKey: mykey) as! String == myvalue, "not affected")
        userDefaults.set(nil, forKey:mykey)
        XCTAssert(userDefaults.object(forKey: mykey) as? String ?? nil == nil, "not nil affected") // return a proxyPreferences

        userDefaults.set(myvalue, forKey:mykey)
        XCTAssert(userDefaults.string(forKey: mykey) == myvalue, "not affected")
        userDefaults.set(nil, forKey:mykey)
        XCTAssert(userDefaults.string(forKey: mykey) == nil, "not nil affected")
    }

    func testUserDefaultsProxy() {
        let userDefaults = Foundation.UserDefaults.standard

        let appKey = "appname"
        let appDefaults = MutableProxyPreferences(preferences: userDefaults, key: appKey, separator: UserDefaultsKeySeparator)

        let fullKey = appKey + UserDefaultsKeySeparator + mykey

        appDefaults[mykey] = myvalue
        XCTAssert(appDefaults[mykey] as! String == myvalue, "not affected")
        XCTAssert(userDefaults[fullKey] as! String == myvalue, "not affected")
        appDefaults[mykey] = nil
        XCTAssert(appDefaults[mykey] as? String ?? nil == nil, "not nil affected")
        XCTAssert(userDefaults[fullKey] as? String ?? nil == nil, "not nil affected")

    }

    func testPreference() {
        let userDefaults = Foundation.UserDefaults.standard

        var intPref: MutablePreference<Int> = userDefaults <| "int"
        intPref.value = nil
        intPref.value = 0

        intPref = userDefaults <| "int"

        intPref += 1
        XCTAssert(intPref.value! == 1)
        intPref -= 1
        XCTAssert(intPref.value! == 0)
        intPref += 30
        XCTAssert(intPref.value! == 30)
        intPref -= 30
        XCTAssert(intPref.value! == 0)

        intPref.value = 1
        XCTAssert(intPref.value! == 1)

        intPref *= 20
        XCTAssert(intPref.value! == 20)
        intPref %= 7
        XCTAssert(intPref.value! == 6)
        intPref %= 2
        XCTAssert(intPref.value! == 0)

        intPref += 30
        intPref /= 3
        XCTAssert(intPref.value! == 10)

        switch(intPref) {
        case 1: XCTFail("not equal in switch")
        case 10: print("ok")
        default: XCTFail("not equal in switch")
        }

        switch(intPref) {
        case 0...9: XCTFail("not equal in switch")
        case 11...999: XCTFail("not equal in switch")
        case 9...11: print("ok")
        default: XCTFail("not equal in switch")
        }


        var boolPref: MutablePreference<Bool> = userDefaults.preference(forKey: "bool")
        boolPref.value = nil

        boolPref &&= false
        XCTAssert(boolPref.value! == false)
        boolPref &&= true
        XCTAssert(boolPref.value! == false)

        boolPref.value = true
        XCTAssert(boolPref.value! == true)
        boolPref &&= true
        XCTAssert(boolPref.value! == true)
        boolPref &&= false
        XCTAssert(boolPref.value! == false)

        boolPref != false
        XCTAssert(boolPref.value! == true)


        boolPref ||= true
        XCTAssert(boolPref.value! == true)
        boolPref ||= false
        XCTAssert(boolPref.value! == true)

        boolPref != true
        XCTAssert(boolPref.value! == false)

        boolPref ||= false
        XCTAssert(boolPref.value! == false)
        boolPref ||= true
        XCTAssert(boolPref.value! == true)

        switch(boolPref) {
        case true: print("ok")
        case false: XCTFail("not true")
        default: XCTFail("nil")
        }

        let anInt: Int = 10
        let intFromBoolPref: MutablePreference<Int> = boolPref.transform { value in
            return (value ?? false) ? anInt : anInt
        }
        guard let v = intFromBoolPref.value else {
            XCTFail("nil value")
            return
        }
        XCTAssertEqual(v, anInt)
        XCTAssertNil(boolPref.value)


        var stringPref: MutablePreference<String> = userDefaults.preference(forKey: "string")
        stringPref.value = "pref"

        stringPref += "erence"
        XCTAssert(stringPref.value! == "preference")

        stringPref.apply { value in
            return value?.uppercased()
        }

        XCTAssert(stringPref.value! == "preference".uppercased())
    }


    func testArchive() {

        var preferences: MutableDictionaryPreferences = [mykey: myvalue, "key2": "value2"]

        let value = Color.blue
        let key = "color"
        preferences[key, .archive] = value


        guard let unarchived = preferences[key, .archive] as? Color else {
            XCTFail("Cannot unarchive \(key)")
            return
        }

        XCTAssertEqual(value, unarchived)

        guard let _ = preferences[key, .none] as? Data else {
            XCTFail("Cannot get data for \(key)")
            return
        }

        guard let _ = preferences[key] as? Data else {
            XCTFail("Cannot get data for \(key)")
            return
        }

        let colorPref: MutablePreference<Color> = preferences <| key
        colorPref.transformationKey = .archive

        guard let _ = colorPref.value else {
            XCTFail("Cannot unarchive \(key)")
            return
        }

        let value2: Color = .red
        colorPref.value = value2

        guard let unarchived2 = preferences[key, .archive] as? Color else {
            XCTFail("Cannot unarchive \(key)")
            return
        }
        XCTAssertEqual(value2, unarchived2)


        let valueDefault: Color = .yellow
        let whenNil = colorPref.whenNil(use: valueDefault)
        colorPref.value = nil
        XCTAssertEqual(valueDefault, whenNil.value)

    }

   func testClosure() {

        var preferences: MutableDictionaryPreferences = [mykey: myvalue, "key2": "value2"]

        let colorDico: [String: Color] = ["blue": .blue, "red": .red]

        func transform(_ obj: Any?) -> Any? {
            if let color = obj as? Color {

                for (name, c) in colorDico {
                    if c == color {
                        return name
                    }
                }
            }
            return nil
        }
        func revert(_ obj: Any?) -> Any? {
            if let name = obj as? String {
                return colorDico[name]
            }
            return nil
        }

    let value: Color = .blue
        let key = "color"
        preferences[key, .closureTuple(transform: transform, revert: revert)] = value


        guard let unarchived = preferences[key, .closureTuple(transform: transform, revert: revert)] as? Color else {
            XCTFail("Cannot unarchive \(key)")
            return
        }

        XCTAssertEqual(value, unarchived)

        guard let _ = preferences[key, .none] as? String else {
            XCTFail("Cannot get string for \(key)")
            return
        }

        guard let _ = preferences[key] as? String else {
            XCTFail("Cannot get string for \(key)")
            return
        }

        let colorPref: MutablePreference<Color> = preferences <| key
        colorPref.transformationKey = .closureTuple(transform: transform, revert: revert)

        guard let _ = colorPref.value else {
            XCTFail("Cannot unarchive \(key)")
            return
        }

    let value2: Color = .red
        colorPref.value = value2

        guard let unarchived2 = preferences[key, .closureTuple(transform: transform, revert: revert)] as? Color else {
            XCTFail("Cannot unarchive \(key)")
            return
        }
        XCTAssertEqual(value2, unarchived2)

    }

    func testReflectingPreferences(){
        var pref = PrefStruc()

        XCTAssertEqual(pref.color, pref["color"] as? String)
        XCTAssertEqual(pref.age, pref["age"] as? Int)
        XCTAssertEqual(pref.enabled, pref["enabled"] as? Bool)

        pref.color = "blue"
        XCTAssertEqual(pref.color, pref["color"] as? String)

        let dico = pref.dictionary()
        XCTAssertEqual(dico.count, 3)
        for key in ["color","age","enabled"] {
            XCTAssertNotNil(dico[key])
        }
    }

    func testBundle() {
        let bundle = Bundle(for: PrephirencesTests.self)

        let applicationName = bundle[.CFBundleName] as? String

        XCTAssertNotNil(applicationName)
    }

    func testNSHTTPCookieStorage() {
        let storage = HTTPCookieStorage.shared
        let key = "name"
        let value = "value"

        var cookieProperties = [HTTPCookiePropertyKey: Any]()
        cookieProperties[HTTPCookiePropertyKey.name] = key
        cookieProperties[HTTPCookiePropertyKey.value] = value
        cookieProperties[HTTPCookiePropertyKey.domain] = "domain"
        cookieProperties[HTTPCookiePropertyKey.path] = "cookie.path"
        cookieProperties[HTTPCookiePropertyKey.version] = NSNumber(value: 1)
        cookieProperties[HTTPCookiePropertyKey.expires] = Date().addingTimeInterval(31536000)
        guard let newCookie = HTTPCookie(properties: cookieProperties) else {
            XCTFail("failed to create cookie")
            return
        }

        storage.setCookie(newCookie)

        let dico = storage.dictionary()
        XCTAssertFalse(dico.isEmpty)

        XCTAssertEqual(storage[key] as? String, value)
    }

    func testCollectionPreference () {
        struct KeyValue {
            var key: String
            var value: AnyObject
        }

        let collection = [
            KeyValue(key:"key", value: "value" as AnyObject),
            KeyValue(key:"key2", value: "value2" as AnyObject)
        ]

        let pref = CollectionPreferencesAdapter(collection: collection, mapKey: {$0.key}, mapValue: {$0.value})

        let dico = pref.dictionary()
        XCTAssertEqual(dico.count, collection.count)


        XCTAssertEqual(pref["key"] as? String, "value")
        XCTAssertEqual(pref["key2"] as? String, "value2")
        XCTAssertNil(pref["unusedkey"])
    }

    func testEnum() {
        let preferences: MutableDictionaryPreferences = [mykey: myvalue, "key2": "value2"]

        let key = "enumTest"
        let pref: MutablePreference<PrefEnum> = preferences <| key
        pref.value = nil
        var value = PrefEnum.Two
        pref.value = value

        pref.transformation = PrefEnum.preferenceTransformation
        pref.value = value
        XCTAssertEqual(pref.value, value)

        let fromPrefs: PrefEnum? = preferences.rawRepresentable(forKey: key)
        XCTAssertEqual(fromPrefs, value)

        value = PrefEnum.Three
        preferences.set(rawValue: value, forKey: key)
        XCTAssertEqual(pref.value, value)
    }

    func testEnsure() {
        let cent = 100
        let modeThan100: (Int?) -> Bool = {
            return $0.map { $0 > cent } ?? false
        }
        var cptDidSet = 0

        var intPref: MutablePreference<Int> = Foundation.UserDefaults.standard <| "intEnsure"
        intPref = intPref.whenNil(use: cent).ensure(when: modeThan100, use: cent).didSet({ (newValue, oldValue) in
            cptDidSet += 1
        })


        var modifCpt = 0
        let value = 80
        intPref.value = value
          modifCpt += 1
        XCTAssertEqual(value, intPref.value)
        intPref.value = nil
        modifCpt += 1
        XCTAssertEqual(intPref.value, cent)
        intPref.value = cent + 20
        modifCpt += 1
        XCTAssertEqual(intPref.value, cent)


        XCTAssertEqual(cptDidSet, modifCpt)
    }

    func testEnumKey() {
        enum TestKey: PreferenceKey {
            case color, age, enabled
        }

        var pref = PrefStruc()

        XCTAssertEqual(pref.color, pref.string(forKey: TestKey.color))
        XCTAssertEqual(pref.age, pref.integer(forKey: TestKey.age))
        XCTAssertEqual(pref.enabled, pref.bool(forKey: TestKey.enabled))

        pref.color = "blue"
        XCTAssertEqual(pref.color, pref.object(forKey: TestKey.color) as? String)
    }
    
    func testOpPrepherence() {
        let value = 4
        let value2 = 2
        let preferences: DictionaryPreferences = [mykey: value, mykey2: value2]
        
        let pref: Preference<Int> = preferences <| mykey
        let pref2: Preference<Int> = preferences <| mykey2

        XCTAssertEqual(pref + pref2, value + value2)
        XCTAssertEqual(pref * pref2, value * value2)
        XCTAssertEqual(pref - pref2, value - value2)
        XCTAssertEqual(pref / pref2, value / value2)
        XCTAssertEqual(pref % pref2, value % value2)
        
    }

    func testOpPreferences() {
        let value = 4
        let value2 = 2
        let preferences: DictionaryPreferences = [mykey: value, mykey2: value2, "array": [value], "array2": [value2]]

        XCTAssertEqual(preferences.operation(on: mykey, with: mykey2, using: +), value + value2)
        XCTAssertEqual(preferences.operation(on: mykey, with: mykey2, using: *), value * value2)
        XCTAssertEqual(preferences.operation(on: mykey, with: mykey2, using: -), value - value2)
        XCTAssertEqual(preferences.operation(on: mykey, with: mykey2, using: /), value / value2)
        XCTAssertEqual(preferences.operation(on: mykey, with: mykey2, using: %), value % value2)

        let _: Int? = preferences.operation(on: mykey, with: mykey2, using: +) // to check compilation
        
        if let result: [Int] = preferences.operation(on: "array", with: "array2", using: +) {
             XCTAssertEqual(result, [value, value2])
        } else {
             XCTFail("failed to get array add op result")
        }
    }

    func testProxyWithString() {
        let value = "4"
        let value2 = "2"
        let dico = [mykey: value, mykey2: value2]
        let preferences: DictionaryPreferences = DictionaryPreferences(dictionary: dico)
        var proxy = preferences.immutableProxy()

        for (key, value) in preferences.dictionary() {
            XCTAssertEqual(proxy.string(forKey: key), value as? String)
        }
        let prefix = "ke"
        proxy = ProxyPreferences(preferences: preferences, key: prefix)
        for (key, value) in preferences.dictionary() {
            let index = key.index(key.startIndex, offsetBy: prefix.count) // to remove "ke"
            XCTAssertEqual(proxy.string(forKey: String(key[index...])), value as? String)
        }

        let proxydico = proxy.dictionary()
        XCTAssertEqual(proxydico.count, dico.count) // will be true if prefix is in all original key
        // check the keys
        for (key, _) in proxydico {
            XCTAssertFalse(key.contains(prefix))
        }
    }

    func testProxyWithInt() {
        let value = 4
        let value2 = 2
        let dico = [mykey: value, mykey2: value2]
        let preferences: DictionaryPreferences = DictionaryPreferences(dictionary: dico)
        var proxy = preferences.immutableProxy()

        // empty prefix so same key
        for (key, value) in preferences.dictionary() {
            XCTAssertEqual(proxy.integer(forKey: key), value as? Int)
        }

        // with prefix so not same key
        let prefix = "ke"
        proxy = ProxyPreferences(preferences: preferences, key: prefix)
        for (key, value) in preferences.dictionary() {
            let index = key.index(key.startIndex, offsetBy: prefix.count) // to remove "ke"
            let newKey = String(key[index...])
            XCTAssertEqual(proxy.integer(forKey: newKey), value as? Int)
        }
    }

    func testMutableProxyWithInteger() {
        let value = 4
        let value2 = 2
        let dico = [mykey: value, mykey2: value2]
        let preferences: MutableDictionaryPreferences = MutableDictionaryPreferences(dictionary: dico)
        var proxy = MutableProxyPreferences(preferences: preferences, key: "")

        for (key, value) in preferences.dictionary() {
            let proxyValue = proxy.integer(forKey: key)
            XCTAssertEqual(proxyValue, value as? Int)
            proxy.set(proxyValue + 2, forKey: key)
            XCTAssertEqual(proxy.integer(forKey: key), preferences.integer(forKey: key))
        }

        let prefix = "ke"
        proxy = MutableProxyPreferences(preferences: preferences, key: prefix)
        for (key, value) in preferences.dictionary() {
            let index = key.index(key.startIndex, offsetBy: prefix.count) // to remove "ke"
            let newKey = String(key[index...])
            let proxyValue = proxy.integer(forKey: newKey)
            XCTAssertEqual(proxyValue, value as? Int)
            proxy.set(proxyValue + 2, forKey: key)
            XCTAssertEqual(proxy.integer(forKey: newKey), preferences.integer(forKey: key))
        }
    }

    func testPrephirencable() {
        var mutable = Prephirences.sharedMutableInstance
        mutable?["myStruct.stringValue"] = "test"
        mutable?["myStruct.mySubLevel.boolValue"] = true
        mutable?["myStruct.mySubLevel.integer"] = 5
        mutable?["myStruct.mySubLevel.integerValue"] = 8

        XCTAssertEqual(MyStruct.stringValue, "test")
        XCTAssertEqual(MyStruct.stringValueLoaded, nil)
        XCTAssertEqual(MyStruct.MySubLevel.boolValue, true)
        XCTAssertEqual(MyStruct.MySubLevel.integer, 5)
        XCTAssertEqual(MyStruct.MySubLevel.integerValue, 8)

        mutable?["myStruct.stringValueLoaded"] = "test2"
        XCTAssertEqual(MyStruct.stringValueLoaded, nil) // must not modified
    }
}

struct PrefStruc {
    var color = "red"
    let age = 33
    let enabled = false
}

extension PrefStruc: ReflectingPreferences {}


enum PrefEnum0: Int {
    case one = 1
    case two = 2
    case three = 3
}
enum PrefEnum: String {
    case One, Two, Three
}

public struct MyStruct: Prephirencable {

    public static let stringValue: String? = instance["stringValue"] as? String
    public static let stringValueLoaded: String? = instance["stringValueLoaded"] as? String

    public struct MySubLevel: Prephirencable { // swiftlint:disable:this nesting
        public static let parent = MyStruct.instance

        public static let boolValue: Bool = instance["boolValue"] as? Bool ?? false
        public static let integer: Int? = instance["integer"] as? Int
        public static let integerValue: Int  = instance["integerValue"] as? Int ?? 0

    }
}
