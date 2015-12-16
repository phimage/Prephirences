//
//  PrephirencesTests.swift
//  PrephirencesTests
//
//  Created by phimage on 05/06/15.
//  Copyright (c) 2015 phimage. All rights reserved.
//

import Foundation
import XCTest
import Prephirences
#if os(iOS)
    import UIKit
#endif
#if os(OSX)
    import AppKit
#endif

class PrephirencesTests: XCTestCase {
    
    let mykey = "key"
    let myvalue = "value"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func printPreferences(preferences: PreferencesType) {
        for (key,value) in preferences.dictionary() {
            print("\(key)=\(value)")
        }
    }
    
    func printDictionaryPreferences(dictionaryPreferences: DictionaryPreferences) {
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
        if let filePath = NSBundle(forClass: self.dynamicType).pathForResource("Test", ofType: "plist") {
            if  let preference = DictionaryPreferences(filePath: filePath) {
                    for (key,value) in preference.dictionary() {
                        print("\(key)=\(value)")
                    }
                    
            } else {
                XCTFail("Failed to read from file")
            }
        }else {
            XCTFail("Failed to get file url")
        }
        
        
        if  let  preference = DictionaryPreferences(filename: "Test", ofType: "plist", bundle: NSBundle(forClass: self.dynamicType)) {
            for (key,value) in preference.dictionary() {
                print("\(key)=\(value)")
            }
            
        } else {
            XCTFail("Failed to read from file using shortcut init")
        }

    }

    func testUserDefaults() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        printPreferences(userDefaults)
        
        
        
        userDefaults[mykey] = myvalue
        XCTAssert(userDefaults[mykey] as! String == myvalue, "not affected")
        userDefaults[mykey] = nil
        XCTAssert(userDefaults[mykey] as? String ?? nil == nil, "not nil affected") // return a proxyPreferences
        
        
        userDefaults.setObject(myvalue, forKey:mykey)
        XCTAssert(userDefaults.objectForKey(mykey) as! String == myvalue, "not affected")
        userDefaults.setObject(nil, forKey:mykey)
        XCTAssert(userDefaults.objectForKey(mykey) as? String ?? nil == nil, "not nil affected") // return a proxyPreferences
        
        userDefaults.setObject(myvalue, forKey:mykey)
        XCTAssert(userDefaults.stringForKey(mykey) == myvalue, "not affected")
        userDefaults.setObject(nil, forKey:mykey)
        XCTAssert(userDefaults.stringForKey(mykey) == nil, "not nil affected")
    }
    
    func testUserDefaultsProxy() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
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
        let userDefaults = NSUserDefaults.standardUserDefaults()
 
        var intPref: MutablePreference<Int> = userDefaults <| "int"
        intPref.value = nil
        intPref.value = 0
        
        intPref = userDefaults <| "int"
        
        intPref++
        XCTAssert(intPref.value! == 1)
        intPref--
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
        
        
        var boolPref: MutablePreference<Bool> = userDefaults.preferenceForKey("bool")
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
        
        let intFromBoolPref : MutablePreference<Int> = boolPref.transform{ value in
            return (value ?? false) ? 1:0
        }
        XCTAssert(intFromBoolPref.value! == 1)
        

        
        var stringPref: MutablePreference<String> = userDefaults.preferenceForKey("string")
        stringPref.value = "pref"
        
        stringPref += "erence"
        XCTAssert(stringPref.value! == "preference")

        stringPref.apply { value in
            return value?.uppercaseString
        }
        
        XCTAssert(stringPref.value! == "preference".uppercaseString)
    }
    
    
    func testArchive() {
        
        var preferences: MutableDictionaryPreferences = [mykey: myvalue, "key2": "value2"]
        
        let value = UIColor.blueColor()
        let key = "color"
        preferences[key, .Archive] = value
        
        
        guard let unarchived = preferences[key, .Archive] as? UIColor else {
            XCTFail("Cannot unarchive \(key)")
            return
        }
        
        XCTAssertEqual(value, unarchived)
        
        guard let _ = preferences[key, .None] as? NSData else {
            XCTFail("Cannot get data for \(key)")
            return
        }
        
        guard let _ = preferences[key] as? NSData else {
            XCTFail("Cannot get data for \(key)")
            return
        }
        
        let colorPref: MutablePreference<UIColor> = preferences <| key
        colorPref.transformation = .Archive
        
        guard let _ = colorPref.value else {
            XCTFail("Cannot unarchive \(key)")
            return
        }
        
        let value2 = UIColor.redColor()
        colorPref.value = value2
        
        guard let unarchived2 = preferences[key, .Archive] as? UIColor else {
            XCTFail("Cannot unarchive \(key)")
            return
        }
        XCTAssertEqual(value2, unarchived2)
        
    }
    
    func testClosure() {
        
        var preferences: MutableDictionaryPreferences = [mykey: myvalue, "key2": "value2"]
        
        let colorDico: [String: UIColor] = ["blue": UIColor.blueColor(), "red": UIColor.redColor()]
        
        func transform(obj: AnyObject?) -> AnyObject? {
            if let color = obj as? UIColor {
                
                for (name, c) in colorDico {
                    if c == color {
                        return name
                    }
                }
            }
            return nil
        }
        func revert(obj: AnyObject?) -> AnyObject? {
            if let name = obj as? String {
                return colorDico[name]
            }
            return nil
        }
        let tuple = (transform: transform, revert: revert)
        
        let value = UIColor.blueColor()
        let key = "color"
        preferences[key, .ClosureTuple(tuple)] = value
        
        
        guard let unarchived = preferences[key, .ClosureTuple(tuple)] as? UIColor else {
            XCTFail("Cannot unarchive \(key)")
            return
        }
        
        XCTAssertEqual(value, unarchived)
        
        guard let _ = preferences[key, .None] as? String else {
            XCTFail("Cannot get string for \(key)")
            return
        }
        
        guard let _ = preferences[key] as? String else {
            XCTFail("Cannot get string for \(key)")
            return
        }
        
        let colorPref: MutablePreference<UIColor> = preferences <| key
        colorPref.transformation = .ClosureTuple(tuple)
        
        guard let _ = colorPref.value else {
            XCTFail("Cannot unarchive \(key)")
            return
        }
        
        let value2 = UIColor.redColor()
        colorPref.value = value2
        
        guard let unarchived2 = preferences[key, .ClosureTuple(tuple)] as? UIColor else {
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
        let bundle = NSBundle(forClass: PrephirencesTests.self)
        
        let applicationName = bundle[.CFBundleName] as? String
        
        XCTAssertNotNil(applicationName)
    }

    func testNSHTTPCookieStorage() {
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        let key = "name"
        let value = "value"

        var cookieProperties = [String: AnyObject]()
        cookieProperties[NSHTTPCookieName] = key
        cookieProperties[NSHTTPCookieValue] = value
        cookieProperties[NSHTTPCookieDomain] = "domain"
        cookieProperties[NSHTTPCookiePath] = "cookie.path"
        cookieProperties[NSHTTPCookieVersion] = NSNumber(integer: 1)
        cookieProperties[NSHTTPCookieExpires] = NSDate().dateByAddingTimeInterval(31536000)
        guard let newCookie = NSHTTPCookie(properties: cookieProperties) else {
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
            KeyValue(key:"key", value: "value"),
            KeyValue(key:"key2", value: "value2")
        ]

        let pref = CollectionPreferencesAdapter(collection: collection, mapKey: {$0.key}, mapValue: {$0.value})

        let dico = pref.dictionary()
        XCTAssertEqual(dico.count, collection.count)


        XCTAssertEqual(pref["key"] as? String, "value")
        XCTAssertEqual(pref["key2"] as? String, "value2")
        XCTAssertNil(pref["unusedkey"])
    }
    
}

struct PrefStruc {
    var color = "red"
    let age = 33
    let enabled = false
}

extension PrefStruc: ReflectingPreferences {}

