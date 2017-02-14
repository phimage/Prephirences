//
//  ManagedObjectPreferences.swift
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
import CoreData

open class ManageObjectPreferences: PreferencesAdapter {
    fileprivate let object: NSManagedObject
    var entityName: String

    public init(_ object: NSManagedObject) {
        self.object = object
        self.entityName = NSStringFromClass(object.classForCoder)
    }

    open func object(forKey key: PreferenceKey) -> PreferenceObject? {
        return self.object.value(forKey: key)
    }

    open func keys() -> [String] {
        let attr = self.object.entity.attributesByName
        return Array(attr.keys)
    }

}

open class MutableManageObjectPreferences: ManageObjectPreferences {

    public override init(_ object: NSManagedObject) {
        super.init(object)
    }

    open subscript(key: PreferenceKey) -> PreferenceObject? {
        get {
            return self.object(forKey: key)
        }
        set {
            self.set(newValue, forKey: key)
        }
    }

}

extension MutableManageObjectPreferences: MutablePreferencesType {
    public func set(_ value: PreferenceObject?, forKey key: PreferenceKey) {
        if self.object.responds(to: NSSelectorFromString(key)) {
            self.object.setValue(value, forKey: key)
        }
    }
    public func removeObject(forKey key: PreferenceKey) {
        if self.object.responds(to: NSSelectorFromString(key)) {
            self.object.setValue(nil, forKey: key)
        }
    }
    public func set(_ value: Int, forKey key: PreferenceKey) {
        self.set(NSNumber(value: value), forKey: key)
    }
    public func set(_ value: Float, forKey key: PreferenceKey) {
        self.set(NSNumber(value: value), forKey: key)
    }
    public func set(_ value: Double, forKey key: PreferenceKey) {
        self.set(NSNumber(value: value), forKey: key)
    }
    public func set(_ value: Bool, forKey key: PreferenceKey) {
        self.set(NSNumber(value: value), forKey: key)
    }
    public func set(url value: URL?, forKey key: PreferenceKey) {
        self.set(url as AnyObject?, forKey: key)
    }
    public func setObjectToArchive(_ value: AnyObject?, forKey key: PreferenceKey) {
        Prephirences.archive(object: value, intoPreferences: self, forKey: key)
    }
    public func clearAll() {
        // not implemented, maybe add protocol to set defaults attributes values
    }
}
