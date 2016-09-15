//
//  UserDefaults+Adds.swift
//  Prephirences
/*
The MIT License (MIT)

Copyright (c) 2016 Eric Marchand (phimage)

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
    
    public func set(color: Color, forKey aKey: String) {
        let theData = NSKeyedArchiver.archivedData(withRootObject: color)
        self.set(theData, forKey:aKey)
    }
    
    public func color(forKey aKey: String) -> Color? {
        if let theData = self.data(forKey: aKey), let color = NSKeyedUnarchiver.unarchiveObject(with: theData) as? Color {
            return color
        }
        return nil
    }
    
    // MARK: CGRect,CGSize,CGPoint
    #if os(OSX)
    private func NSStringFromCGRect(_ value: CGRect) -> String {
        return NSStringFromRect(NSRectFromCGRect(value))
    }
    
    private func NSStringFromCGSize(_ value: CGSize) -> String {
        return NSStringFromSize(NSSizeFromCGSize(value))
    }
    
    private func NSStringFromCGPoint(_ value: CGPoint) -> String {
        return NSStringFromPoint(NSPointFromCGPoint(value))
    }
    
    private func CGRectFromString(_ value: String) -> CGRect {
        return NSRectToCGRect(NSRectFromString(value))
    }
    
    private func CGSizeFromString(_ value: String) -> CGSize {
        return NSSizeToCGSize(NSSizeFromString(value))
    }
    
    private func CGPointFromString(_ value: String) -> CGPoint {
        return NSPointToCGPoint(NSPointFromString(value))
    }
    #endif

    public func cgRect(forKey key: PreferenceKey) -> CGRect? {
        if let string = self.string(forKey: key) {
            return CGRectFromString(string)
        }
        return nil
    }
    
    @nonobjc public func set(_ value: CGRect, forKey key: PreferenceKey) {
        self.set(NSStringFromCGRect(value), forKey: key)
    }
    
    public func cgSize(forKey key: PreferenceKey) -> CGSize? {
        if let string = self.string(forKey: key) {
            return CGSizeFromString(string)
        }
        return nil
    }

    @nonobjc public func set(_ value: CGSize, forKey key: PreferenceKey) {
        self.set(NSStringFromCGSize(value), forKey: key)
    }
    
    public func cgPoint(forKey key: PreferenceKey) -> CGPoint? {
        if let string = self.string(forKey: key) {
            return CGPointFromString(string)
        }
        return nil
    }

    @nonobjc public func set(_ value: CGPoint, forKey key: PreferenceKey) {
        self.set(NSStringFromCGPoint(value), forKey: key)
    }
    
    #if os(OSX)
    // MARK: NSRect
    public func nsRectForKey(key: String) -> NSRect? {
        if let string = self.string(forKey: key) {
            return NSRectFromString(string)
        }
        return nil
    }

    
    // MARK: NSSize
    public func nsSizeForKey(key: String) -> NSSize? {
        if let string = self.string(forKey: key) {
            return NSSizeFromString(string)
        }
        return nil
    }
    #endif
    
}

//MARK: Global shortcut
public let UserDefaults = Foundation.UserDefaults.standard
public var UserDefaultsKeySeparator = "."

#if os(OSX)
    import AppKit
    public var UserDefaultsController = NSUserDefaultsController.shared()
    
    // http://stackoverflow.com/questions/29312106/xcode-6-os-x-storyboard-multiple-user-defaults-controllers-bug-with-multiple-sce/29509031#29509031
    @objc(SharedUserDefaultsControllerProxy)
    public class SharedUserDefaultsControllerProxy: NSObject {
        lazy var defaults = UserDefaultsController
    }
#endif
