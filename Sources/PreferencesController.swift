//
//  PreferencesController.swift
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

@objc(PreferencesKVCHelper)
open class PreferencesKVCHelper: NSObject { // NSKeyValueCoding

    open var preferences: MutablePreferencesType?

    public init(preferences: MutablePreferencesType?) {
        self.preferences = preferences
    }

    // informal NSKeyValueCoding
    open override func value(forKey key: PreferenceKey) -> Any? {
        return preferences?[key]
    }

    open override func setValue(_ value: Any?, forKey key: PreferenceKey) {
        self.willChangeValue(forKey: key)
        preferences?[key] = value
        self.didChangeValue(forKey: key)
    }

}

#if os(OSX)
    import AppKit

    @objc(PreferencesController)
    public class PreferencesController: NSController {

        public var values = PreferencesKVCHelper(preferences: nil)

        public static let sharedUserDefaultsController = PreferencesController(preferences: Foundation.UserDefaults.standard)

        public override init() {
            super.init()
        }

        public convenience init(preferences: MutablePreferencesType?) {
            self.init()
            self.values.preferences = preferences
        }

        public required init?(coder: NSCoder) {
            super.init(coder: coder)
        }

    }

    @objc(UserDefaultsPreferencesControllerProxy)
    public class UserDefaultsPreferencesControllerProxy: NSObject {
        lazy var defaults = PreferencesController.sharedUserDefaultsController
    }

#endif
