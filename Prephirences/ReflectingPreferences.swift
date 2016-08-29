//
//  ReflectingPreferences.swift
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

// Protocol to extends to get properties as preferences using Reflection
public protocol ReflectingPreferences: PreferencesType {
}

extension ReflectingPreferences {

    public func objectForKey(key: String) -> AnyObject? {
        let mirror = Mirror(reflecting: self)
        // guard let style = mirror.displayStyle where style == .Struct || style == .Class else { return nil }

        return mirror.children.find{$0.label == key}?.value as? AnyObject
    }

    public func dictionary() -> [String : AnyObject] {
        let mirror = Mirror(reflecting: self)
        // guard let style = mirror.displayStyle where style == .Struct || style == .Class else { return [String : AnyObject]() }

        let transform: (Mirror.Child) -> (String,AnyObject)? = { child in
            if let label = child.label, value = child.value as? AnyObject {
                return (label, value)
            }
            return nil
        }

        return mirror.children.dictionary(transform)
    }

    public var keys: [String] {
        return Mirror(reflecting: self).children.flatMap { $0.label }
    }

}

// Protocol to extends to get and set properties as preferences using Reflection
private protocol MutableReflectingPreferences: ReflectingPreferences, MutablePreferencesType {
}

private extension MutableReflectingPreferences where Self: NSObject {

    func setObject(value: PreferenceObject?, forKey key: PreferenceKey) {
        setValue(value, forKey: key)
        // will fail for a let(read only) variable
    }

    func removeObjectForKey(key: String) {
        setValue(nil, forKey: key)
        // will fail if cannot be nil
    }

}


private extension ReflectingPreferences where Self: NSObject {
    
    private func addObserver() {
        keys.forEach {
            addObserver(self, forKeyPath: $0, options: .New, context: nil)
        }
    }
    
    private func removeObserver() {
        keys.forEach {
            removeObserver(self, forKeyPath: $0)
        }
    }
    
    func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>, preferences: MutablePreferencesType, storeKey: (String) -> String = {$0}) {
        if let keyPath = keyPath {
            if let value = change?["new"] where !(value is NSNull) {
                preferences.setObject(value is NSCoding ? NSKeyedArchiver.archivedDataWithRootObject(value) : value, forKey: storeKey(keyPath))
            }else{
                preferences.removeObjectForKey(storeKey(keyPath))
            }
            preferences.synchronize()
        }
    }
    
    private func setupProperty(preferences: MutablePreferencesType, storeKey: (String) -> String = {$0}) {
        keys.forEach {
            let value = preferences.objectForKey(storeKey($0))
            if let data = value as? NSData, decodedValue = NSKeyedUnarchiver.unarchiveObjectWithData(data) {
                setValue(decodedValue, forKey: $0)
            }else{
                setValue(value, forKey: $0)
            }
        }
    }

    private func register(preferences: MutablePreferencesType, storeKey: (String) -> String = {$0}) {
        let dic = keys.reduce([String:AnyObject]()) { (dic, key) -> [String:AnyObject] in
            var mutableDic = dic
            mutableDic[storeKey(key)] = valueForKey(key)
            return mutableDic
        }
        preferences.setObjectsForKeysWithDictionary(dic)
    }
}

// Extends this class instead of NSObject and properties will be backed into preferences (by default standards NSUserDefaults)
private class BackedPreferencesObject: NSObject, ReflectingPreferences  {
    let preferences: MutablePreferencesType
    
    
    private init(preferences: MutablePreferencesType = NSUserDefaults.standardUserDefaults()) {
        self.preferences = preferences
        super.init()
        
        self.register(self.preferences, storeKey: self.storeKey)
        self.setupProperty(self.preferences, storeKey: self.storeKey)
        self.addObserver()
    }
    
    deinit {
        self.removeObserver()
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        self.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context, preferences: preferences, storeKey: self.storeKey)
    }
    
    private func storeKey(propertyName: String) -> String{
        return "\(self.dynamicType)_\(propertyName)"
    }
    
}
