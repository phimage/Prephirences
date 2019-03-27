//
//  NSUserDefaults+Adds.swift
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

public extension PreferencesType {

    func object<R: RawRepresentable>(forKey rawRepresentableKey: R) -> PreferenceObject? where R.RawValue == PreferenceKey {
        return object(forKey: rawRepresentableKey.rawValue)
    }

    /*public subscript<R: RawRepresentable where R.RawValue == PreferenceKey>(rawRepresentableKey: R) -> PreferenceObject? {
      return self[rawRepresentableKey.rawValue]
    }*/

    func hasObject<R: RawRepresentable>(forKey rawRepresentableKey: R) -> Bool where R.RawValue == PreferenceKey {
        return hasObject(forKey: rawRepresentableKey.rawValue)
    }

    func string<R: RawRepresentable>(forKey rawRepresentableKey: R) -> String? where R.RawValue == PreferenceKey {
        return string(forKey: rawRepresentableKey.rawValue)
    }

    func array<R: RawRepresentable>(forKey rawRepresentableKey: R) -> [PreferenceObject]? where R.RawValue == PreferenceKey {
        return array(forKey: rawRepresentableKey.rawValue)
    }

    func dictionary<R: RawRepresentable>(forKey rawRepresentableKey: R) -> [PreferenceKey: PreferenceObject]? where R.RawValue == PreferenceKey {
        return dictionary(forKey: rawRepresentableKey.rawValue)
    }

    func data<R: RawRepresentable>(forKey rawRepresentableKey: R) -> Data? where R.RawValue == PreferenceKey {
        return data(forKey: rawRepresentableKey.rawValue)
    }

    func stringArray<R: RawRepresentable>(forKey rawRepresentableKey: R) -> [String]? where R.RawValue == PreferenceKey {
        return stringArray(forKey: rawRepresentableKey.rawValue)
    }

    func integer<R: RawRepresentable>(forKey rawRepresentableKey: R) -> Int where R.RawValue == PreferenceKey {
        return integer(forKey: rawRepresentableKey.rawValue)
    }

    func float<R: RawRepresentable>(forKey rawRepresentableKey: R) -> Float where R.RawValue == PreferenceKey {
        return float(forKey: rawRepresentableKey.rawValue)
    }

    func double<R: RawRepresentable>(forKey rawRepresentableKey: R) -> Double where R.RawValue == PreferenceKey {
        return double(forKey: rawRepresentableKey.rawValue)
    }

    func bool<R: RawRepresentable>(forKey rawRepresentableKey: R) -> Bool where R.RawValue == PreferenceKey {
        return bool(forKey: rawRepresentableKey.rawValue)
    }

    func url<R: RawRepresentable>(forKey rawRepresentableKey: R) -> URL? where R.RawValue == PreferenceKey {
        return url(forKey: rawRepresentableKey.rawValue)
    }

    func rawRepresentable<T: RawRepresentable, R: RawRepresentable>(forKey rawRepresentableKey: R) -> T? where R.RawValue == PreferenceKey {
        return self.rawRepresentable(forKey: rawRepresentableKey.rawValue)
    }

}

public extension MutablePreferencesType {

    func set<R: RawRepresentable>(_ value: PreferenceObject?, rawRepresentableKey: R) where R.RawValue == PreferenceKey {
        set(value, forKey: rawRepresentableKey.rawValue)
    }

    func removeObject<R: RawRepresentable>(forKey rawRepresentableKey: R) where R.RawValue == PreferenceKey {
        removeObject(forKey: rawRepresentableKey.rawValue)
    }

    func set<R: RawRepresentable>(_ value: Int, rawRepresentableKey: R) where R.RawValue == PreferenceKey {
        set(value, forKey: rawRepresentableKey.rawValue)
    }

    func set<R: RawRepresentable>(_ value: Float, rawRepresentableKey: R) where R.RawValue == PreferenceKey {
        set(value, forKey: rawRepresentableKey.rawValue)
    }

    func set<R: RawRepresentable>(_ value: Double, rawRepresentableKey: R) where R.RawValue == PreferenceKey {
        set(value, forKey: rawRepresentableKey.rawValue)
    }

    func set<R: RawRepresentable>(_ value: Bool, rawRepresentableKey: R) where R.RawValue == PreferenceKey {
        set(value, forKey: rawRepresentableKey.rawValue)
    }

    func set<R: RawRepresentable>(_ url: URL?, rawRepresentableKey: R) where R.RawValue == PreferenceKey {
        set(url, forKey: rawRepresentableKey.rawValue)
    }

    func set<T: RawRepresentable, R: RawRepresentable>(rawValue value: T?, rawRepresentableKey: R) where R.RawValue == PreferenceKey {
        self.set(rawValue: value, forKey: rawRepresentableKey.rawValue)
    }

}

open class PreferenceSerializable<ValueType>: RawRepresentable {
    public typealias RawValue = PreferenceKey
    public let rawValue: PreferenceKey

    public required init(rawValue: PreferenceKey) {
        self.rawValue = rawValue
    }
}

// There is no generic subscript in swift 3, so multiple function by type
extension MutablePreferencesType {
    public subscript(key: PreferenceSerializable<String?>) -> String? {
        get { return string(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }

    public subscript(key: PreferenceSerializable<String>) -> String {
        get { return string(forKey: key.rawValue) ?? "" }
        set { set(key, forKey: newValue) }
    }

    public subscript(key: PreferenceSerializable<Int?>) -> Int? {
        get { return object(forKey: key.rawValue) as? Int }
        set { set(newValue, forKey: key.rawValue) }
    }

    public subscript(key: PreferenceSerializable<Int>) -> Int {
        get { return integer(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }

    public subscript(key: PreferenceSerializable<Double?>) -> Double? {
        get { return object(forKey: key.rawValue) as? Double}
        set { set(newValue, forKey: key.rawValue) }
    }

    public subscript(key: PreferenceSerializable<Double>) -> Double {
        get { return double(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }

    public subscript(key: PreferenceSerializable<Bool?>) -> Bool? {
        get { return object(forKey: key.rawValue) as? Bool }
        set { set(newValue, forKey: key.rawValue) }
    }

    public subscript(key: PreferenceSerializable<Bool>) -> Bool {
        get { return bool(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }

    public subscript(key: PreferenceSerializable<Any?>) -> Any? {
        get { return object(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }

    public subscript(key: PreferenceSerializable<Data?>) -> Data? {
        get { return data(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }

    public subscript(key: PreferenceSerializable<Data>) -> Data {
        get { return data(forKey: key.rawValue) ?? Data() }
        set { set(newValue, forKey: key.rawValue) }
    }

    public subscript(key: PreferenceSerializable<Date?>) -> Date? {
        get { return object(forKey: key.rawValue) as? Date }
        set { set(newValue, forKey: key.rawValue) }
    }

    public subscript(key: PreferenceSerializable<URL?>) -> URL? {
        get { return url(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }

    public subscript(key: PreferenceSerializable<[String: Any]?>) -> [String: Any]? {
        get { return dictionary(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }

    public subscript(key: PreferenceSerializable<[String: Any]>) -> [String: Any] {
        get { return dictionary(forKey: key.rawValue) ?? [:] }
        set { set(newValue, forKey: key.rawValue) }
    }

    public subscript(key: PreferenceSerializable<[Any]?>) -> [Any]? {
        get { return array(forKey: key.rawValue) }
        set { set(newValue, forKey: key.rawValue) }
    }

    public subscript(key: PreferenceSerializable<[Any]>) -> [Any] {
        get { return array(forKey: key.rawValue) ?? [] }
        set { set(newValue, forKey: key.rawValue) }
    }
}
