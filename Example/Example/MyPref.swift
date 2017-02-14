//
//  MyPref.swift
//  Example
//
//  Created by phimage on 27/07/16.
//  Copyright © 2016 phimage. All rights reserved.
//

import Foundation
import Prephirences


// MARK: Plist
let AppConfig = Plist(filename: "config")!
// List of key from plist (could use also string key)
enum PlistKey: String {
    case string
    case number
    case bool
}

/// A subscript to use with PlistKey
extension PreferencesType {
    subscript(key: PlistKey) -> AnyObject? {
        return self[key.rawValue]
    }
}

// MARK: NSUserDefaults
let UserDefaults = NSUserDefaults.standardUserDefaults()

class FromDefaults { // or extension NSUserDefaults or other model class ...
    /// example of variable binded on UserDefaults
    static let stringKey = "DefaultKeyString"
    static var string: String? {
        get {
            return UserDefaults[stringKey] as? String
        }
        set {
            UserDefaults[stringKey]  = newValue
        }
    }
}

// MARK: Compose some preferences
let StaticKey = "key"
let StaticValue = "value"
let StaticConfig: DictionaryPreferences = [StaticKey: StaticValue]
let MainBundle = NSBundle.mainBundle()
let Preferences: MutableCompositePreferences = [StaticConfig, AppConfig, UserDefaults, MainBundle]
