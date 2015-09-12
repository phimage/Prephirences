//
//  NSUbiquitousKeyValueStore+Prephirences.swift
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

/** Prephirences Extends NSUbiquitousKeyValueStore

*/
extension NSUbiquitousKeyValueStore : MutablePreferencesType {

    public func dictionary() -> [String : AnyObject] {
        return self.dictionaryRepresentation
    }
    public func hasObjectForKey(key: String) -> Bool {
        return objectForKey(key) != nil
    }
    public func clearAll() {
        for(key,_) in self.dictionaryRepresentation {
            removeObjectForKey(key as String)
        }
    }
    
    public func setObjectsForKeysWithDictionary(dictionary: [String:AnyObject]) {
        for (key, value) in dictionary {
            self.setObject(value, forKey: key)
        }
    }
    
    public func stringArrayForKey(key: String) -> [String]? {
        return arrayForKey(key) as? [String]
    }
    
    // MARK: number
    
    public func integerForKey(key: String) -> Int {
        return Int(longLongForKey(key))
    }
    public func floatForKey(key: String) -> Float {
        return Float(doubleForKey(key))
    }

    public func setInteger(value: Int, forKey key: String){
        setLongLong(Int64(value), forKey: key)
    }
    public func setFloat(value: Float, forKey key: String){
        setDouble(Double(value), forKey: key)
    }

    // MARK: url
    
    public func URLForKey(key: String) -> NSURL? {
        if let bookData = self.dataForKey(key) {
            var isStale : ObjCBool = false
            let error : NSErrorPointer = nil
            #if os(OSX)
            let options = NSURLBookmarkResolutionOptions.WithSecurityScope
            #elseif os(iOS)
            let options = NSURLBookmarkResolutionOptions.WithoutUI
            #endif
            
            do {
                let url = try NSURL(byResolvingBookmarkData: bookData, options: options, relativeToURL: nil, bookmarkDataIsStale: &isStale)
                if error == nil {
                    return url
                }
            } catch let error1 as NSError {
                error.memory = error1
            }
        }
        return nil
    }
    
    public func setURL(url: NSURL?, forKey key: String) {
        if let urlToSet = url {
            #if os(OSX)
                let options = NSURLBookmarkCreationOptions.WithSecurityScope.union(.SecurityScopeAllowOnlyReadAccess)
                #elseif os(iOS)
                let options = NSURLBookmarkCreationOptions()
            #endif
            let data: NSData?
            do {
                data = try urlToSet.bookmarkDataWithOptions(options, includingResourceValuesForKeys:nil, relativeToURL:nil)
            } catch _ {
                data = nil
            }
            setData(data, forKey: key)
        }
        else {
            removeObjectForKey(key)
        }
    }
    
    // MARK: archive
    public func unarchiveObjectForKey(key: String) -> AnyObject? {
        return Prephirences.unarchiveObject(self, forKey: key)
    }
    public func setObjectToArchive(value: AnyObject?, forKey key: String) {
        Prephirences.archiveObject(value, preferences: self, forKey: key)
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