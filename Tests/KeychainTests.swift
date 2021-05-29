//
//  KeychainTests.swift
//  PrephirencesiOSTests
//
//  Created by phimage on 26/06/2018.
//  Copyright © 2018 phimage. All rights reserved.
//

import XCTest
@testable import Prephirences

#if os(OSX)

class KeychainTests: XCTestCase {

    let mykey = "key"
    let myvalue = "value"
    let myvalue2 = "value2"

    let keychain = KeychainPreferences(service: Bundle(for: KeychainTests.self).bundleIdentifier ?? "test")
    //let keychain = KeychainPreferences.sharedInstance

    override func setUp() {
        super.setUp()
        keychain.accessible = .always
        
        //#if os(iOS)
        // ProcessInfo.processInfo.environment["ENTITLEMENTS_REQUIRED"]
        //#endif
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testKeychain() {
        keychain[mykey] = myvalue
        XCTAssertEqual(keychain.lastStatus, errSecSuccess)
        let attribute = keychain.attribute(forKey: mykey)
        XCTAssertNotNil(attribute, "attribute must not be nil")
        XCTAssertNotNil(attribute?.creationDate, "attribute creationDate must not be nil")

        let affected = keychain[mykey]
        XCTAssertNotNil(affected, "not affected")
        let affectedAsString: String? = keychain[string: mykey]
        XCTAssertNotNil(affectedAsString, "not affected")
        XCTAssertEqual(affectedAsString, myvalue)

        keychain[mykey] = myvalue2
        XCTAssertEqual(keychain.lastStatus, errSecSuccess)
        let attribute2 = keychain.attribute(forKey: mykey)
        XCTAssertNotNil(attribute2, "attribute must not be nil")
        XCTAssertNotNil(attribute2?.modificationDate, "attribute modificationDate must not be nil")
        let affected2 = keychain[mykey]
        XCTAssertNotNil(affected2, "not affected")
        let affectedAsString2: String? = keychain[string: mykey]
        XCTAssertNotNil(affectedAsString2, "not affected")
        XCTAssertEqual(affectedAsString2, myvalue2)

        keychain[mykey] = nil
        XCTAssertEqual(keychain.lastStatus, errSecSuccess)
        XCTAssertNil(keychain[mykey], "not nil affected")

        keychain.set(myvalue, forKey:mykey)
        XCTAssert(keychain.string(forKey: mykey) == myvalue, "not affected")
        keychain.set(nil, forKey:mykey)
        XCTAssertNil(keychain.string(forKey: mykey), "not nil affected")
        XCTAssertNil(keychain[mykey], "not nil affected")
    }

    func testKeychainAll() {
        keychain["keychainall"] = true
        XCTAssertEqual(keychain.lastStatus, errSecSuccess)

        let keys = keychain.keys()
        XCTAssertFalse(keys.isEmpty)
        let dico = keychain.dictionary()
        XCTAssertFalse(dico.isEmpty)

        keychain["keychainall"] = nil
    }
}

#endif
