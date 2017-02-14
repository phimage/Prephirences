//
//  PreferenceOperators.swift
//  Prephirences
//
//  Created by phimage on 29/08/16.
//  Copyright (c) 2017 Eric Marchand (phimage). All rights reserved.
//

#if os(Linux)
    import Glibc
#else
    import Darwin
    import CoreGraphics
#if os(watchOS)
    import UIKit
#endif
#endif

// MARK: - operators

// Assign optional

infix operator ?=: AssignmentPrecedence
public func ?=<T> (preference: MutablePreference<T>, expr: @autoclosure () -> T) {
    if !preference.hasValue {
        preference.value = expr()
    }
}

// MARK: Pattern match
// infix operator ~=: ComparaisonPrecedence
public func ~=<T: Equatable> (value: T, preference: Preference<T>) -> Bool {
    if let pv = preference.value {
        return pv ~= value
    }
    return false
}
public func ~=<T: Equatable> (preference: Preference<T>, value: T) -> Bool {
    if let pv = preference.value {
        return pv ~= value
    }
    return false
}

public func ~=<B: Comparable> (value: CountableClosedRange<B>, preference: Preference<B>) -> Bool {
    if let pv = preference.value {
        return value ~= pv
    }
    return false
}
public func ~=<B: Comparable> (preference: Preference<B>, value: CountableClosedRange<B>) -> Bool {
    if let pv = preference.value {
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
    if let left = left.value {
        if let right = right.value {
           return left < right
        }
        return true
    }
    if let _ = right.value { // left nil
        return true
    }
    return false // strict when equal
}

// MARK: helper protocol to get a default value
public protocol Initializable {
    init() // get a zero
}
extension Int: Initializable {}
extension Float: Initializable {}
extension Double: Initializable {}
extension UInt8: Initializable {}
extension Int8: Initializable {}
extension UInt16: Initializable {}
extension Int16: Initializable {}
extension UInt32: Initializable {}
extension Int32: Initializable {}
extension UInt64: Initializable {}
extension Int64: Initializable {}
extension UInt: Initializable {}
extension CGFloat: Initializable {}

extension String: Initializable {}
extension Array: Initializable {}
extension Bool: Initializable {}

// MARK: IntegerArithmetic
public func +=<T> (preference: inout MutablePreference<T>, addend: T) where T:IntegerArithmetic, T:Initializable {
    let c = preference.value ?? T()
    preference.value = c + addend
}
public func -=<T> (preference: inout MutablePreference<T>, addend: T) where T:IntegerArithmetic, T:Initializable {
    let c = preference.value ?? T()
    preference.value = c - addend
}

public func *=<T> (preference: inout MutablePreference<T>, multiplier : T) where T:IntegerArithmetic, T:Initializable {
    let c = preference.value ?? T()
    preference.value = c * multiplier
}

public func /=<T> (preference: inout MutablePreference<T>, divisor : T) where T:IntegerArithmetic, T:Initializable {
    let c = preference.value ?? T()
    preference.value = c / divisor
}

public func %=<T> (preference: inout MutablePreference<T>, modulo : T) where T:IntegerArithmetic, T:Initializable {
    let c = preference.value ?? T()
    preference.value = c % modulo
}

// MARK: Bitwise Operations
public func &= <T>(preference: inout MutablePreference<T>, rhs: T) where T: BitwiseOperations, T:Initializable {
    let c = preference.value ?? T()
    preference.value = c & rhs
}
public func |= <T>(preference: inout MutablePreference<T>, rhs: T) where T: BitwiseOperations, T:Initializable {
    let c = preference.value ?? T()
    preference.value = c | rhs
}
public func ^=<T> (preference: inout MutablePreference<T>, rhs: T) where T: BitwiseOperations, T:Initializable {
    let c = preference.value ?? T()
    preference.value = c ^ rhs
}
public func ~= <T>(preference: inout MutablePreference<T>, rhs: T) where T: BitwiseOperations {
    preference.value = ~rhs
}

// MARK: Addable
public protocol Addable {
    static func + (left: Self, right: Self) -> Self
}
extension String: Addable {}
extension Array: Addable {}

public func +=<T> (preference: inout MutablePreference<T>, addend: T) where T:Addable, T:Initializable {
    let c = preference.value ?? T()
    preference.value = c + addend
}

// MARK: LogicalOperationsType
public protocol LogicalOperationsType: Conjunctive, Disjunctive {
    static prefix func ! (value: Self) -> Self // NOT
}
extension Bool: LogicalOperationsType {}

public func !=<T: LogicalOperationsType> ( preference: inout MutablePreference<T>, right:  @autoclosure () -> T) {
    preference.value = !right()
}

/// MARK: Conjunctive
public protocol Conjunctive {
    static func && (left: Self, right:  @autoclosure () throws -> Self) rethrows -> Self // AND
}
infix operator &&= : AssignmentPrecedence
extension Conjunctive {
    public static func &&= (lhs: inout Self, rhs: Self) {
        lhs = lhs && rhs
    }
}

public func && <T>(left: MutablePreference<T>, right: Preference<T>) -> T where T: Conjunctive, T:Initializable {
    let leftV = left.value ?? T()
    let rightV = right.value ?? T()
    return leftV && rightV
}
public func &&=<T> (preference: inout MutablePreference<T>, right: @autoclosure () throws -> T) rethrows where T:Conjunctive, T:Initializable {
    let c = preference.value ?? T()
    try preference.value = c && right
}

/// MARK: Disjunctive
public protocol Disjunctive {
    static func || (left: Self, right:  @autoclosure () throws -> Self) rethrows -> Self // OR
}
infix operator ||= : AssignmentPrecedence
extension Disjunctive {
    public static func ||= (lhs: inout Self, rhs: Self) {
        lhs = lhs || rhs
    }
}

public func ||=<T> (preference: inout MutablePreference<T>, rhs: @autoclosure () throws -> T) rethrows where T: Disjunctive, T: Initializable {
    let c = preference.value ?? T()
    try preference.value = c || rhs
}

public func || <T>(left: MutablePreference<T>, right: Preference<T>) -> T where T: Disjunctive, T:Initializable {
    let leftV = left.value ?? T()
    let rightV = right.value ?? T()
    return leftV || rightV
}
