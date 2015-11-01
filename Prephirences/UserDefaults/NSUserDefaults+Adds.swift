//
//  NSUserDefaults+Adds.swift
//  Prephirences
/*
The MIT License (MIT)

Copyright (c) 2015 Eric Marchand (phimage)

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
public extension NSUserDefaults {

    // MARK: color
    #if os(OSX)
    typealias Color = NSColor
    #elseif os(iOS) || os(watchOS) || os(tvOS)
    typealias Color = UIColor
    #endif
    
    public func setColor(aColor: Color, forKey aKey: String) {
        let theData = NSKeyedArchiver.archivedDataWithRootObject(aColor)
        self.setObject(theData, forKey:aKey)
    }
    
    public func colorForKey(aKey: String) -> Color? {
        if let theData = self.dataForKey(aKey), color = NSKeyedUnarchiver.unarchiveObjectWithData(theData) as? Color {
            return color
        }
        return nil
    }
    
    // MARK: CGRect,CGSize,CGPoint
    #if os(OSX)
    private func NSStringFromCGRect(value: CGRect) -> String {
        return NSStringFromRect(NSRectFromCGRect(value))
    }
    
    private func NSStringFromCGSize(value: CGSize) -> String {
        return NSStringFromSize(NSSizeFromCGSize(value))
    }
    
    private func NSStringFromCGPoint(value: CGPoint) -> String {
        return NSStringFromPoint(NSPointFromCGPoint(value))
    }
    
    private func CGRectFromString(value: String) -> CGRect {
        return NSRectToCGRect(NSRectFromString(value))
    }
    
    private func CGSizeFromString(value: String) -> CGSize {
        return NSSizeToCGSize(NSSizeFromString(value))
    }
    
    private func CGPointFromString(value: String) -> CGPoint {
        return NSPointToCGPoint(NSPointFromString(value))
    }
    #endif

    public func cgRectForKey(key: String) -> CGRect? {
        if let string = self.stringForKey(key) {
            return CGRectFromString(string)
        }
        return nil
    }
    
    public func setCGRect(value: CGRect, forKey key: String) {
        self.setObject(NSStringFromCGRect(value), forKey: key)
    }
    
    public func cgSizeForKey(key: String) -> CGSize? {
        if let string = self.stringForKey(key) {
            return CGSizeFromString(string)
        }
        return nil
    }
    
    public func setCGSize(value: CGSize, forKey key: String) {
        self.setObject(NSStringFromCGSize(value), forKey: key)
    }
    
    public func cgPointForKey(key: String) -> CGPoint? {
        if let string = self.stringForKey(key) {
            return CGPointFromString(string)
        }
        return nil
    }
    
    public func setCGPoint(value: CGPoint, forKey key: String) {
        self.setObject(NSStringFromCGPoint(value), forKey: key)
    }
    
    #if os(OSX)
    // MARK: NSRect
    public func nsRectForKey(key: String) -> NSRect? {
        if let string = self.stringForKey(key) {
            return NSRectFromString(string)
        }
        return nil
    }
    
    public func setNSRect(value: NSRect, forKey key: String) {
        self.setObject(NSStringFromRect(value), forKey: key)
    }
    
    // MARK: NSSize
    public func nsSizeForKey(key: String) -> NSSize? {
        if let string = self.stringForKey(key) {
            return NSSizeFromString(string)
        }
        return nil
    }
    
    public func setNSSize(value: NSSize, forKey key: String) {
        self.setObject(NSStringFromSize(value), forKey: key)
    }
    #endif
    
}

//MARK: Global shortcut
public let UserDefaults = NSUserDefaults.standardUserDefaults()
public var UserDefaultsKeySeparator = "."

#if os(OSX)
    import Cocoa
    public let UserDefaultsController = NSUserDefaultsController.sharedUserDefaultsController()
    
    // http://stackoverflow.com/questions/29312106/xcode-6-os-x-storyboard-multiple-user-defaults-controllers-bug-with-multiple-sce/29509031#29509031
    @objc(SharedUserDefaultsControllerProxy)
    public class SharedUserDefaultsControllerProxy: NSObject {
        lazy var defaults = UserDefaultsController
    }
#endif
