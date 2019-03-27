//
//  UserDefaults+Adds.swift
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
#if os(iOS) || os(watchOS) || os(tvOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif

// MARK: additionnal types
public extension Foundation.UserDefaults {

    // MARK: color
    #if os(OSX)
    typealias Color = NSColor
    #elseif os(iOS) || os(watchOS) || os(tvOS)
    typealias Color = UIColor
    #endif

    func set(color: Color, forKey aKey: String) {
        let theData = NSKeyedArchiver.archivedData(withRootObject: color)
        self.set(theData, forKey: aKey)
    }

    func color(forKey aKey: String) -> Color? {
        if let theData = self.data(forKey: aKey), let color = NSKeyedUnarchiver.unarchiveObject(with: theData) as? Color {
            return color
        }
        return nil
    }

    func cgRect(forKey key: PreferenceKey) -> CGRect? {
        if let string = self.string(forKey: key) {
            return NSCoder.cgRect(for: string)
        }
        return nil
    }

    @nonobjc func set(_ value: CGRect, forKey key: PreferenceKey) {
        self.set(NSCoder.string(for: value), forKey: key)
    }

    func cgSize(forKey key: PreferenceKey) -> CGSize? {
        if let string = self.string(forKey: key) {
            return NSCoder.cgSize(for: string)
        }
        return nil
    }

    @nonobjc func set(_ value: CGSize, forKey key: PreferenceKey) {
        self.set(NSCoder.string(for: value), forKey: key)
    }

    func cgPoint(forKey key: PreferenceKey) -> CGPoint? {
        if let string = self.string(forKey: key) {
            return NSCoder.cgPoint(for: string)
        }
        return nil
    }

    @nonobjc func set(_ value: CGPoint, forKey key: PreferenceKey) {
        self.set(NSCoder.string(for: value), forKey: key)
    }

    #if os(OSX)
    // MARK: NSRect
    func nsRectForKey(key: String) -> NSRect? {
        if let string = self.string(forKey: key) {
            return NSRectFromString(string)
        }
        return nil
    }

    // MARK: NSSize
    func nsSizeForKey(key: String) -> NSSize? {
        if let string = self.string(forKey: key) {
            return NSCoder.cgSize(for: string)
        }
        return nil
    }
    #endif

}

// MARK: Global shortcut
public var UserDefaultsKeySeparator = "."

#if os(OSX)
import AppKit
public var UserDefaultsController = NSUserDefaultsController.shared

// http://stackoverflow.com/questions/29312106/xcode-6-os-x-storyboard-multiple-user-defaults-controllers-bug-with-multiple-sce/29509031#29509031
@objc(SharedUserDefaultsControllerProxy)
public class SharedUserDefaultsControllerProxy: NSObject {
    lazy var defaults = UserDefaultsController
}

extension NSCoder {
    static func cgRect(for string: String) -> CGRect {
        return NSRectToCGRect(NSRectFromString(string))
    }
    static func cgSize(for string: String) -> CGSize {
        return NSSizeToCGSize(NSSizeFromString(string))
    }
    static func cgPoint(for string: String) -> CGPoint {
        return NSPointToCGPoint(NSPointFromString(string))
    }
    static func string(for value: CGRect) -> String {
        return NSStringFromRect(NSRectFromCGRect(value))
    }
    static func string(for value: CGSize) -> String {
        return NSStringFromSize(NSSizeFromCGSize(value))
    }
    static func string(for value: CGPoint) -> String {
        return NSStringFromPoint(NSPointFromCGPoint(value))
    }
}
#else

#if swift(>=4.2)
#else
extension NSCoder {
    static func cgRect(for string: String) -> CGRect {
        return CGRectFromString(string)
    }
    static func cgSize(for string: String) -> CGSize {
        return CGSizeFromString(string)
    }
    static func cgPoint(for string: String) -> CGPoint {
        return CGPointFromString(string)
    }
    static func string(for value: CGRect) -> String {
        return NSStringFromCGRect(value)
    }
    static func string(for value: CGSize) -> String {
        return NSStringFromCGSize(value)
    }
    static func string(for value: CGPoint) -> String {
        return NSStringFromCGPoint(value)
    }
}
#endif
#endif
