//
//  ReflectingPreferences.swift
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

public protocol ReflectingPreferences: PreferencesType {}

extension ReflectingPreferences {

    public func object(forKey key: PreferenceKey) -> PreferenceObject? {
        let mirror = Mirror(reflecting: self)
        // guard let style = mirror.displayStyle where style == .Struct || style == .Class else { return nil }

        return mirror.children.find {$0.label == key}?.value
    }

    public func dictionary() -> PreferencesDictionary {
        let mirror = Mirror(reflecting: self)
        // guard let style = mirror.displayStyle where style == .Struct || style == .Class else { return [String : AnyObject]() }

        let transform: (Mirror.Child) -> (PreferenceKey, PreferenceObject)? = { child in
            if let label = child.label {
                return (label, child.value)
            }
            return nil
        }

        return mirror.children.dictionary(transform)
    }

}
