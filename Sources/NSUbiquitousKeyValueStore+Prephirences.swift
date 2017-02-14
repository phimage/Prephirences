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

    public func dictionary() -> PreferencesDictionary {
        return self.dictionaryRepresentation
    }

    public func stringArray(forKey key: PreferenceKey) -> [String]? {
        return array(forKey: key) as? [String]
    }

    // MARK: number

    public func integer(forKey key: PreferenceKey) -> Int {
        return Int(longLong(forKey: key))
    }
    public func float(forKey key: PreferenceKey) -> Float {
        return Float(double(forKey: key))
    }

    @nonobjc public func set(_ value: Int, forKey key: PreferenceKey) {
        set(Int64(value), forKey: key)
    }

    @nonobjc public func set(_ value: Float, forKey key: PreferenceKey) {
        set(Double(value), forKey: key)
    }
}

// MARK: url
extension NSUbiquitousKeyValueStore {

    public func url(forKey key: PreferenceKey) -> URL? {
        if let bookData = self.data(forKey: key) {
            var isStale: ObjCBool = false
            #if os(OSX)
            let options = NSURL.BookmarkResolutionOptions.withSecurityScope
            #elseif os(iOS) || os(watchOS) || os(tvOS)
            let options = URL.BookmarkResolutionOptions.withoutUI
            #endif

            do {
                let url = try (NSURL(resolvingBookmarkData: bookData, options: options, relativeTo: nil, bookmarkDataIsStale: &isStale) as URL)
                set(url, forKey: key)
                return url
            } catch { }
        }

        return nil
    }

    public func set(_ url: URL?, forKey key: PreferenceKey) {
        if let urlToSet = url {
            #if os(OSX)
                let options = URL.BookmarkCreationOptions.withSecurityScope.union(.securityScopeAllowOnlyReadAccess)
                #elseif os(iOS) || os(watchOS) || os(tvOS)
                let options = URL.BookmarkCreationOptions()
            #endif
            let data: Data?
            do {
                data = try urlToSet.bookmarkData(options: options, includingResourceValuesForKeys:nil, relativeTo:nil)
            } catch _ {
                data = nil
            }
            set(data, forKey: key)
        } else {
            removeObject(forKey: key)
        }
    }

}
