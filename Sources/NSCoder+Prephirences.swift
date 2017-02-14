//
//  NSCoder+Prephirences.swift
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

extension NSCoder: PreferencesType {

    public func object(forKey key: PreferenceKey) -> PreferenceObject? {
        return self.decodeObject(forKey: key)
    }
    public func hasObject(forKey key: PreferenceKey) -> Bool {
        return self.containsValue(forKey: key)
    }
    public func dictionary() -> PreferencesDictionary {
        return  [:]
    }
    public func integer(forKey key: PreferenceKey) -> Int {
        return self.decodeInteger(forKey: key)
    }
    public func float(forKey key: PreferenceKey) -> Float {
        return self.decodeFloat(forKey: key)
    }
    public func double(forKey key: PreferenceKey) -> Double {
        return self.decodeDouble(forKey: key)
    }
    public func bool(forKey key: PreferenceKey) -> Bool {
        return self.decodeBool(forKey: key)
    }
}

extension NSCoder: MutablePreferencesType {

    public func set(_ value: PreferenceObject?, forKey key: PreferenceKey) {
        self.encode(value, forKey: key)
    }
    public func removeObject(forKey key: PreferenceKey) {
        self.encode(nil, forKey: key)
    }
    /* public func set(_ value: Int, forKey key: PreferenceKey) {
        self.encode(value, forKey: key)
    }
    public func set(_ value: Float, forKey key: PreferenceKey) {
        self.encode(value, forKey: key)
    }
    public func set(_ value: Double, forKey key: PreferenceKey) {
        self.encode(value, forKey: key)
    }
    public func set(_ value: Bool, forKey key: PreferenceKey) {
        self.encode(value, forKey: key)
    }*/

}
