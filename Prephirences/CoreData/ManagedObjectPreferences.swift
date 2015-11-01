//
//  ManagedObjectPreferences.swift
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
import CoreData

public class ManageObjectPreferences : PreferencesAdapter {
    private let object: NSManagedObject
    var entityName: String
    
    public init(_ object: NSManagedObject) {
        self.object = object
        self.entityName = NSStringFromClass(object.classForCoder)
    }
    
    public func objectForKey(key: String) -> AnyObject? {
        return self.object.valueForKey(key)
    }
    
    public func keys() -> [String] {
        let attr = self.object.entity.attributesByName
        return Array(attr.keys)
    }
    
}

public class MutableManageObjectPreferences: ManageObjectPreferences {
    
    public override init(_ object: NSManagedObject) {
        super.init(object)
    }
    
    public subscript(key: String) -> AnyObject? {
        get {
            return self.objectForKey(key)
        }
        set {
            self.setObject(newValue, forKey: key)
        }
    }
    
}

extension MutableManageObjectPreferences: MutablePreferencesType {
    public func setObject(value: AnyObject?, forKey key: String){
        if (self.object.respondsToSelector(NSSelectorFromString(key))) {
            self.object.setValue(value, forKey: key)
        }
    }
    public func removeObjectForKey(key: String){
        if (self.object.respondsToSelector(NSSelectorFromString(key))) {
            self.object.setValue(nil, forKey: key)
        }
    }
    public func setInteger(value: Int, forKey key: String){
        self.setObject(NSNumber(integer: value), forKey: key)
    }
    public func setFloat(value: Float, forKey key: String){
        self.setObject(NSNumber(float: value), forKey: key)
    }
    public func setDouble(value: Double, forKey key: String){
        self.setObject(NSNumber(double: value), forKey: key)
    }
    public func setBool(value: Bool, forKey key: String){
        self.setObject(NSNumber(bool: value), forKey: key)
    }
    public func setURL(url: NSURL?, forKey key: String){
        self.setObject(url, forKey: key)
    }
    public func setObjectToArchive(value: AnyObject?, forKey key: String) {
        Prephirences.archiveObject(value, preferences: self, forKey: key)
    }
    public func clearAll(){
        // not implemented, maybe add protocol to set defaults attributes values
    }
}