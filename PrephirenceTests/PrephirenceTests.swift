//
//  PrephirenceTests.swift
//  PrephirenceTests
//
//  Created by phimage on 22/04/15.
//  Copyright (c) 2015 phimage. All rights reserved.
//

import Foundation
import XCTest
import PrephirenceMacOSX

class PrephirenceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFromDictionary() {
        if let url = NSBundle(forClass: self.dynamicType).URLForResource("Info", withExtension: "plist"),
            filePath = url.absoluteString,
            dico = NSDictionary(contentsOfFile: filePath)
             {
                var preference = DictionaryPreferences(dico: dico as! Dictionary<String, AnyObject>)
                for (key,value) in preference.dictionaryRepresentation() {
                    println("\(key)=\(value)")
                }
                
        } else {
            XCTFail("Failed to read from file to test from dico")
        }
    }
    /*
    func testFromFile() {
        if let url = NSBundle(forClass: self.dynamicType).URLForResource("Info", withExtension: "plist"),
            filePath = url.absoluteString,
            preference = DictionaryPreferences(filePath: filePath) {
                for (key,value) in preference.dictionaryRepresentation() {
                    println("\(key)=\(value)")
                }
                
        } else {
            XCTFail("Failed to read from file")
        }
    }*/
    
}
