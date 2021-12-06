//
//  Prephirencable.swift
//  PrephirencesiOS
//
//  Created by Eric Marchand on 19/03/2019.
//  Copyright © 2019 phimage. All rights reserved.
//

import Foundation

/// Protocol to create preferences from Struct hierarchy
/// by creating keypath using the Struct name.
public protocol Prephirencable {
    static var key: String {get}
    static var parent: PreferencesType {get}
}

public extension Prephirencable {
    static var key: String {
        return "\(self)".lowercasingFirst + "."
    }
    static var parent: PreferencesType {
        return Prephirences.sharedMutableInstance ?? Prephirences.sharedInstance
    }
    static var instance: PreferencesType {
        return ProxyPreferences(preferences: parent, key: key)
    }
    static var mutableInstance: MutablePreferencesType? {
        guard let parent = parent as? MutablePreferencesType else {
            return nil
        }
        return MutableProxyPreferences(preferences: parent, key: key)
    }
}
extension String {

    fileprivate var lowercasingFirst: String {
        return prefix(1).lowercased() + dropFirst()
    }
}
