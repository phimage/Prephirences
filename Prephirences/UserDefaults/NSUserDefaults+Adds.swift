//
//  NSUserDefaults+Adds.swift
//  Prephirences
//
//  Created by phimage on 26/04/15.
//  Copyright (c) 2015 phimage. All rights reserved.
//

import Foundation
#if os(iOS)
    import UIKit
#endif
#if os(OSX)
    import Cocoa
#endif

// MARK: utility methods
public extension NSUserDefaults {
    
    public func setObjects(objects: [AnyObject], forKeys keys: [String]) {
        for var keyIndex = 0; keyIndex < keys.count; keyIndex++ {
            self.setObject(objects[keyIndex], forKey: keys [keyIndex])
        }
    }


    
    public func copyDefaults(defaults: NSUserDefaults) {
        let dict = defaults.dictionaryRepresentation()
        for (key, value) in dict {
            setObject(value, forKey: key as! String)
        }
    }
}

// MARK: additionnal types
public extension NSUserDefaults {

    // MARK: color
    #if os(OSX)
    typealias Color = NSColor
    typealias Archiver = NSArchiver
    typealias Unarchiver = NSUnarchiver
    #endif
    #if os(iOS)
    typealias Color = UIColor
    typealias Archiver = NSKeyedArchiver
    typealias Unarchiver = NSKeyedUnarchiver
    #endif
    
    public func setColor(aColor: Color, forKey aKey: String) {
        let theData = Archiver.archivedDataWithRootObject(aColor)
        self.setObject(theData, forKey:aKey)
    }
    
    public func colorForKey(aKey: String) -> Color? {
        if let theData = self.dataForKey(aKey), color = Unarchiver.unarchiveObjectWithData(theData) as? Color {
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
