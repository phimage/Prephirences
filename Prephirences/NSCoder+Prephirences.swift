//
//  NSCoder+Prephirences.swift
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

extension NSCoder: PreferencesType {
    
    public func objectForKey(key: String) -> AnyObject? {
        return self.decodeObjectForKey(key)
    }
    public func hasObjectForKey(key: String) -> Bool {
        return self.containsValueForKey(key)
    }
    public func dictionary() -> [String : AnyObject] {
        return  [:]
    }
    public func integerForKey(key: String) -> Int {
        return self.decodeIntegerForKey(key)
    }
    public func floatForKey(key: String) -> Float {
        return self.decodeFloatForKey(key)
    }
    public func doubleForKey(key: String) -> Double {
        return self.decodeDoubleForKey(key)
    }
    public func boolForKey(key: String) -> Bool {
        return self.decodeBoolForKey(key)
    }
}

extension NSCoder: MutablePreferencesType {
    
    public func setObject(value: AnyObject?, forKey key: String) {
        self.encodeObject(value, forKey: key)
    }
    public func removeObjectForKey(key: String) {
        self.encodeObject(nil, forKey: key)
    }
    public func setInteger(value: Int, forKey key: String) {
        self.encodeInteger(value, forKey: key)
    }
    public func setFloat(value: Float, forKey key: String) {
        self.encodeFloat(value, forKey: key)
    }
    public func setDouble(value: Double, forKey key: String) {
        self.encodeDouble(value, forKey: key)
    }
    public func setBool(value: Bool, forKey key: String) {
        self.encodeBool(value, forKey: key)
    }

}