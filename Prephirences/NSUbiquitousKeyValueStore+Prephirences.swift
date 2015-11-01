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
            #if os(OSX)
            let options = NSURLBookmarkResolutionOptions.WithSecurityScope
            #elseif os(iOS) || os(watchOS) || os(tvOS)
            let options = NSURLBookmarkResolutionOptions.WithoutUI
            #endif
            
            do {
                let url = try NSURL(byResolvingBookmarkData: bookData, options: options, relativeToURL: nil, bookmarkDataIsStale: &isStale)
                return url
            } catch { }
        }
        return nil
    }
    
    public func setURL(url: NSURL?, forKey key: String) {
        if let urlToSet = url {
            #if os(OSX)
                let options = NSURLBookmarkCreationOptions.WithSecurityScope.union(.SecurityScopeAllowOnlyReadAccess)
                #elseif os(iOS) || os(watchOS) || os(tvOS)
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

}
