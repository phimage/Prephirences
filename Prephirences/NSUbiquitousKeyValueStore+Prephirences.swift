//
//  NSUbiquitousKeyValueStore+Prephirences.swift
//  Prephirences
//
//  Created by phimage on 26/04/15.
//  Copyright (c) 2015 phimage. All rights reserved.
//

import Foundation

/** Prephirences Extends NSUbiquitousKeyValueStore

*/
extension NSUbiquitousKeyValueStore : MutablePreferencesType {

    public func dictionary() -> [String : AnyObject] {
        return self.dictionaryRepresentation as! [String:AnyObject]
    }
    public func hasObjectForKey(key: String) -> Bool {
        return objectForKey(key) != nil
    }
    public func clearAll() {
        for(key,value) in self.dictionaryRepresentation {
            removeObjectForKey(key as! String)
        }
    }
    
    public func setObjectsForKeysWithDictionary(dictionary: [String:AnyObject]) {
        for (key, value) in dictionary {
            self.setObject(value, forKey: key)
        }
    }
    
    // MARK: number
    
    public func integerForKey(key: String) -> Int {
        return Int(longLongForKey(key))
    }
    public func floatForKey(key: String) -> Float {
        return Float(doubleForKey(key))
    }

    public func setInteger(value: Int, forKey key: String){
        setLongLong(Int64(value.value), forKey: key)
    }
    public func setFloat(value: Float, forKey key: String){
        setDouble(Double(value), forKey: key)
    }

    // MARK: url
    
    public func URLForKey(key: String) -> NSURL? {
        if let bookData = self.dataForKey(key) {
            var isStale : ObjCBool = false
            var error : NSErrorPointer = nil
            if let url = NSURL(byResolvingBookmarkData: bookData, options: .WithSecurityScope, relativeToURL: nil, bookmarkDataIsStale: &isStale, error: error) {
                if error == nil {
                    return url
                }
            }
        }
        return nil
    }
    
    public func setURL(url: NSURL, forKey key: String) {
        let data = url.bookmarkDataWithOptions(.WithSecurityScope | .SecurityScopeAllowOnlyReadAccess, includingResourceValuesForKeys:nil, relativeToURL:nil, error:nil)
        setData(data, forKey: key)
    }
}

//MARK: subscript access
extension NSUbiquitousKeyValueStore {
    
    public subscript(key: String) -> AnyObject? {
        get {
            return self.objectForKey(key)
        }
        set {
            if newValue == nil {
                removeObjectForKey(key)
            } else {
                setObject(newValue, forKey: key)
            }
        }
    }
    
}