//
//  NSUserDefaults+Adds.swift
//  Prephirences
/*
 The MIT License (MIT)
 
 Copyright (c) 2016 Eric Marchand (phimage)
 
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

public extension PreferencesType {
    
    public func objectForKey<R: RawRepresentable where R.RawValue == PreferenceKey>(rawRepresentableKey: R) -> PreferenceObject? {
        return objectForKey(rawRepresentableKey.rawValue)
    }

    /*public subscript<R: RawRepresentable where R.RawValue == PreferenceKey>(rawRepresentableKey: R) -> PreferenceObject? {
      return self[rawRepresentableKey.rawValue]
    }*/

   public func hasObjectForKey<R: RawRepresentable where R.RawValue == PreferenceKey>(rawRepresentableKey: R) -> Bool {
        return hasObjectForKey(rawRepresentableKey.rawValue)
    }

    public func stringForKey<R: RawRepresentable where R.RawValue == PreferenceKey>(rawRepresentableKey: R) -> String? {
        return stringForKey(rawRepresentableKey.rawValue)
    }
    
    public func arrayForKey<R: RawRepresentable where R.RawValue == PreferenceKey>(rawRepresentableKey: R) -> [AnyObject]? {
        return arrayForKey(rawRepresentableKey.rawValue)
    }
    
    public func dictionaryForKey<R: RawRepresentable where R.RawValue == PreferenceKey>(rawRepresentableKey: R) -> [String : AnyObject]? {
        return dictionaryForKey(rawRepresentableKey.rawValue)
    }
    
    public func dataForKey<R: RawRepresentable where R.RawValue == PreferenceKey>(rawRepresentableKey: R) -> NSData? {
        return dataForKey(rawRepresentableKey.rawValue)
    }
    
    public func stringArrayForKey<R: RawRepresentable where R.RawValue == PreferenceKey>(rawRepresentableKey: R) -> [String]? {
        return stringArrayForKey(rawRepresentableKey.rawValue)
    }
    
    public func integerForKey<R: RawRepresentable where R.RawValue == PreferenceKey>(rawRepresentableKey: R) -> Int {
        return integerForKey(rawRepresentableKey.rawValue)
    }
    
    public func floatForKey<R: RawRepresentable where R.RawValue == PreferenceKey>(rawRepresentableKey: R) -> Float {
        return floatForKey(rawRepresentableKey.rawValue)
    }
    
    public func doubleForKey<R: RawRepresentable where R.RawValue == PreferenceKey>(rawRepresentableKey: R) -> Double {
        return doubleForKey(rawRepresentableKey.rawValue)
    }
    
    public func boolForKey<R: RawRepresentable where R.RawValue == PreferenceKey>(rawRepresentableKey: R) -> Bool {
        return boolForKey(rawRepresentableKey.rawValue)
    }
    
    public func URLForKey<R: RawRepresentable where R.RawValue == PreferenceKey>(rawRepresentableKey: R) -> NSURL? {
        return URLForKey(rawRepresentableKey.rawValue)
    }

    public func rawRepresentableForKey<T: RawRepresentable, R: RawRepresentable where R.RawValue == PreferenceKey>(rawRepresentableKey: R) -> T? {
        return self.rawRepresentableForKey(rawRepresentableKey.rawValue)
    }
    
}

public extension MutablePreferencesType {
    
    public func setObject<R: RawRepresentable where R.RawValue == PreferenceKey>(value: PreferenceObject?, forKey rawRepresentableKey: R) {
        setObject(value, forKey: rawRepresentableKey.rawValue)
    }
    
    public func removeObjectForKey<R: RawRepresentable where R.RawValue == PreferenceKey>(rawRepresentableKey: R) {
        removeObjectForKey(rawRepresentableKey.rawValue)
    }

    public func setInteger<R: RawRepresentable where R.RawValue == PreferenceKey>(value: Int, forKey rawRepresentableKey: R) {
        setInteger(value, forKey: rawRepresentableKey.rawValue)
    }
    
    public func setFloat<R: RawRepresentable where R.RawValue == PreferenceKey>(value: Float, forKey rawRepresentableKey: R) {
        setFloat(value, forKey: rawRepresentableKey.rawValue)
    }
    
    public func setDouble<R: RawRepresentable where R.RawValue == PreferenceKey>(value: Double, forKey rawRepresentableKey: R) {
        setDouble(value, forKey: rawRepresentableKey.rawValue)
    }
    
    public func setBool<R: RawRepresentable where R.RawValue == PreferenceKey>(value: Bool, forKey rawRepresentableKey: R) {
        setBool(value, forKey: rawRepresentableKey.rawValue)
    }
    
    public func setURL<R: RawRepresentable where R.RawValue == PreferenceKey>(url: NSURL?, forKey rawRepresentableKey: R) {
        setURL(url, forKey: rawRepresentableKey.rawValue)
    }
    
    public func setRawValue<T: RawRepresentable, R: RawRepresentable where R.RawValue == PreferenceKey>(value: T?, forKey rawRepresentableKey: R) {
        self.setRawValue(value, forKey: rawRepresentableKey.rawValue)
    }

}
