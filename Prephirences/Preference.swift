//
//  Preference.swift
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

/* A preference value extracted from a PreferencesType for a specific key */
public class Preference<T> {

    var preferences: PreferencesType
    public let key: String
    
    public init(preferences: PreferencesType, key: String) {
        self.preferences = preferences
        self.key = key
    }
    
    public var value: T? {
        get {
            return self.preferences.objectForKey(self.key) as? T
        }
    }
    
    public var hasValue: Bool {
        return self.preferences.hasObjectForKey(self.key)
    }
}

public class MutablePreference<T>: Preference<T> {
    
    var mutablePreferences: MutablePreferencesType {
        return preferences as! MutablePreferencesType
    }
    
    public init(preferences: MutablePreferencesType, key: String) {
        super.init(preferences: preferences, key: key)
    }
    
    override public var value: T? {
        get {
            return self.preferences.objectForKey(self.key) as? T
        }
        set {
            if let any: AnyObject = newValue as? AnyObject {
                self.mutablePreferences.setObject(any, forKey: self.key)
            }else {
                self.mutablePreferences.removeObjectForKey(self.key)
            }
        }
    }
    
}
// MARK: - operators

// Assign optional
infix operator ?= {
  associativity right
  precedence 90
}

public func ?=<T> (preference: MutablePreference<T>, @autoclosure expr: () -> T) {
    if !preference.hasValue {
        preference.value = expr()
    }
}

// MARK: Pattern match
public func ~=<T: Equatable> (value: T, preference: Preference<T>) -> Bool {
    if let pv = preference.value  {
        return pv ~= value
    }
    return false
}
public func ~=<I: IntervalType> (value: I.Bound, preference: Preference<I>) -> Bool {
    if let pv = preference.value  {
        return pv ~= value
    }
    return false
}
public func ~=<I: ForwardIndexType where I : Comparable> (value: Range<I>, preference: Preference<I>) -> Bool {
    if let pv = preference.value  {
        return value ~= pv
    }
    return false
}

// MARK: Equatable
public func ==<T: Equatable> (left: Preference<T>, right: Preference<T>) -> Bool {
    return left.value == right.value
}
public func !=<T: Equatable> (left: Preference<T>, right: Preference<T>) -> Bool {
    return !(left == right)
}

// MARK: Comparable
public func < <T: Comparable> (left: Preference<T>, right: Preference<T>) -> Bool {
    return left.value < right.value
}

// MARK: Addable
public func +=<T where T:Addable, T:Initializable> (inout preference: MutablePreference<T>, addend: T) {
    let c = preference.value ?? T()
    preference.value = c + addend
}
public func -=<T where T:Substractable, T:Initializable> (inout preference: MutablePreference<T>, addend: T) {
    let c = preference.value ?? T()
    preference.value = c - addend
}

// MARK: Incrementable
public postfix func ++<T where T:IntegerLiteralConvertible, T:Addable, T:Initializable> (inout preference: MutablePreference<T>) -> MutablePreference<T> {
    let increment: T = 1
    preference += increment
    return preference
}

public postfix func --<T where T:IntegerLiteralConvertible, T:Substractable, T:Initializable> (inout preference: MutablePreference<T>) -> MutablePreference<T> {
    let increment: T = 1
    preference -= increment
    return preference
}

// MARK: Multiplicable
public func *=<T where T:Multiplicable, T:Initializable> (inout preference: MutablePreference<T>, multiplier : T) {
    let c = preference.value ?? T()
    preference.value = c * multiplier
}

// MARK: Dividable
public func /=<T where T:Dividable, T:Initializable> (inout preference: MutablePreference<T>, divisor : T) {
    let c = preference.value ?? T()
    preference.value = c / divisor
}

// MARK: Modulable
public func %=<T where T:Modulable, T:Initializable> (inout preference: MutablePreference<T>, modulo : T) {
    let c = preference.value ?? T()
    preference.value = c % modulo
}

// MARK: Logical Operations
infix operator &&= {
associativity right
precedence 90
assignment
}
public func &&=<T where T:LogicalOperationsType, T:Initializable> (inout preference: MutablePreference<T>, @autoclosure right:  () throws -> T) rethrows {
    let c = preference.value ?? T()
    try preference.value = c && right
}
infix operator ||= {
associativity right
precedence 90
assignment
}
public func ||=<T where T:LogicalOperationsType, T:Initializable> (inout preference: MutablePreference<T>, @autoclosure right:  () throws -> T) rethrows {
    let c = preference.value ?? T()
    try preference.value = c || right
}

public func !=<T where T:LogicalOperationsType> (inout preference: MutablePreference<T>, @autoclosure right:  () -> T) {
    preference.value = !right()
}

// MARK: Bitwise Operations
public func &=<T where T: BitwiseOperationsType, T:Initializable>(inout preference: MutablePreference<T>, rhs: T) {
    let c = preference.value ?? T()
    preference.value = c & rhs
}
public func |=<T where T: BitwiseOperationsType, T:Initializable>(inout preference: MutablePreference<T>, rhs: T) {
    let c = preference.value ?? T()
    preference.value = c | rhs
}
public func ^=<T where T: BitwiseOperationsType, T:Initializable>(inout preference: MutablePreference<T>, rhs: T)  {
    let c = preference.value ?? T()
    preference.value = c ^ rhs
}
public func ~=<T where T: BitwiseOperationsType>(inout preference: MutablePreference<T>, rhs: T) {
    preference.value = ~rhs
}


// MARK: Make type implement protocols
// TODO extract a math framework which defines this following protocols : see https://github.com/phimage/Arithmosophi
// OR use IntegerArithmeticType ?

public protocol Initializable {
    init() // get a zero
}

public protocol Addable {
    func + (lhs: Self, rhs: Self) -> Self
}
public protocol Substractable {
    func - (left: Self, right: Self) -> Self
}
public protocol Negatable {
    prefix func - (instance: Self) -> Self
}
public protocol Multiplicable {
    func * (lhs: Self, rhs: Self) -> Self
}
public protocol Dividable {
    func / (left: Self, right: Self) -> Self
}
public protocol Modulable {
    func % (left: Self, right: Self) -> Self
}

extension String: Initializable, Addable {}
extension Array: Initializable, Addable {}
extension Int: Initializable, Addable, Negatable, Substractable, Multiplicable, Dividable, Modulable {}
extension Float: Initializable, Addable, Negatable, Substractable, Multiplicable, Dividable, Modulable {}
extension Double: Initializable, Addable, Negatable, Substractable, Multiplicable, Dividable, Modulable {}
extension UInt8: Addable, Substractable, Multiplicable, Dividable, Modulable {}
extension Int8: Initializable, Addable, Negatable, Substractable, Multiplicable, Dividable, Modulable {}
extension UInt16: Addable, Substractable, Multiplicable, Dividable, Modulable {}
extension Int16: Initializable, Addable, Negatable, Substractable, Multiplicable, Dividable, Modulable {}
extension UInt32: Addable, Substractable, Multiplicable, Dividable, Modulable {}
extension Int32: Initializable, Addable, Negatable, Substractable, Multiplicable, Dividable, Modulable {}
extension UInt64: Addable, Substractable, Multiplicable, Dividable, Modulable {}
extension Int64: Initializable, Addable, Negatable, Substractable, Multiplicable, Dividable, Modulable {}
extension UInt: Addable, Substractable, Multiplicable, Dividable, Modulable{}

#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit // import CoreGraphics
#endif
extension CoreGraphics.CGFloat: Initializable, Addable, Negatable, Substractable, Multiplicable, Dividable, Modulable {}
    
public protocol LogicalOperationsType {
    
    func && (left: Self, @autoclosure right:  () throws -> Self) rethrows -> Self // AND
    func || (left: Self, @autoclosure right:  () throws -> Self) rethrows -> Self // OR
    prefix func ! (left: Self) -> Self // NOT
}

//@rethrows public func ||<T : BooleanType>(lhs: T, @autoclosure rhs: () throws -> Bool) rethrows -> Bool

extension Bool: Initializable, LogicalOperationsType {}

// MARK: -Sum

prefix operator ∑ {}

public prefix func ∑<T where T:Addable, T:Initializable>(input: [T]) -> T {
    return sumOf(input)
}

public func sumOf<T where T: Addable, T:Initializable>(input : T...) -> T {
    return sumOf(input)
}

public func sumOf<T where T:Addable, T:Initializable>(input : [T]) -> T {
    return input.reduce(T()) {$0 + $1}
}

