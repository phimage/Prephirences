//
//  PrephirencesTests.swift
//  PrephirencesTests
//
//  Created by phimage on 22/04/15.
//  Copyright (c) 2015 phimage. All rights reserved.
//

import Foundation
import XCTest
#if os(iOS)
    import PrephirencesiOS
#endif
#if os(OSX)
    import PrephirencesMacOSX
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
    
    /*func testFromFile() {
        if let url = NSBundle(forClass: self.dynamicType).URLForResource("Test", withExtension: "plist"),
            filePath = url.absoluteString,
            dico = NSDictionary(contentsOfFile: filePath),
            preference = DictionaryPreferences(filePath: filePath) {
                for (key,value) in preference.dictionaryRepresentation() {
                    println("\(key)=\(value)")
                }
                
        } else {
            XCTFail("Failed to read from file")
        }
    }*/
    
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
    
    func testUserDefaultsProxu() {
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
    
}
