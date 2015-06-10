//
//  PrephirencesiOSTests.swift
//  PrephirencesiOSTests
//
//  Created by phimage on 05/06/15.
//  Copyright (c) 2015 phimage. All rights reserved.
//

import Foundation
import XCTest
#if os(iOS)
    import PrephirencesiOS
    import UIKit
#endif
#if os(OSX)
    import PrephirencesMacOSX
    import AppKit
#endif

class PrephirencesiOSTests: XCTestCase {
    
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
            println("\(key)=\(value)")
        }
    }
    
    func printDictionaryPreferences(dictionaryPreferences: DictionaryPreferences) {
        printPreferences(dictionaryPreferences)
        for (key,value) in dictionaryPreferences {
            println("\(key)=\(value)")
        }
    }
    
    func testFromDictionary() {
        var preferences = DictionaryPreferences(dictionary: [mykey: myvalue, "key2": "value2"])
        printDictionaryPreferences(preferences)
    }
    
    func testFromDictionaryLiteral() {
        var preferences: DictionaryPreferences = [mykey: myvalue, "key2": "value2"]
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
                        println("\(key)=\(value)")
                    }
                    
            } else {
                XCTFail("Failed to read from file")
            }
        }else {
            XCTFail("Failed to get file url")
        }
        
        
        if  let  preference = DictionaryPreferences(filename: "Test", ofType: "plist", bundle: NSBundle(forClass: self.dynamicType)) {
            for (key,value) in preference.dictionary() {
                println("\(key)=\(value)")
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
 
        var intPref: MutablePreference<Int> = Prephirences.preferenceForKey("int", userDefaults)
        intPref.value = nil
        
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
        
        
        var boolPref: MutablePreference<Bool> = Prephirences.preferenceForKey("bool", userDefaults)
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
    }
    
}