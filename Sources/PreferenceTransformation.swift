//
//  PreferenceTransformation.swift
//  Prephirences
//
//  Created by phimage on 08/09/16.
//  Copyright (c) 2017 Eric Marchand (phimage). All rights reserved.
//

import Foundation

// MARK: - transformation, archive

// Protocol to modify stored and read values
public typealias PreferenceTransformationObject = Any
public protocol PreferenceTransformation {
    // Transform value when reading it
    func reverseTransformedValue(_ value: PreferenceObject?) -> PreferenceTransformationObject?
    // Transform any value before storing it
    func transformedValue(_ value: PreferenceTransformationObject?) -> PreferenceObject?
}

public enum TransformationKey {
    // Default value: do nothing to values
    case none

    // Archive and unarchive for NSCoding objects
    case archive

    // Use closures to transform
    case closureTuple(transform: ((PreferenceTransformationObject?) -> PreferenceObject?)?, revert: (PreferenceObject?) -> PreferenceTransformationObject?)

    // Use RawValue for raw representable objects
    // case Raw // XXX find a generic way to cast to RawRepresentable

    // Chain multiple transformations
    case compose(transformations: [PreferenceTransformation])

    #if !os(Linux)
    // Apply an NSValueTransformer
    case valueTransformer(Foundation.ValueTransformer)
    #endif
}

extension TransformationKey {

    static func smartCompose(left transformation: PreferenceTransformation, right transformation2: PreferenceTransformation) -> PreferenceTransformation {
        // if .None return the other
        if let key = transformation as? TransformationKey, key == TransformationKey.none {
            return transformation2
        } else if let key = transformation2 as? TransformationKey, key == TransformationKey.none {
            return transformation
        }
        // first Compose, just append
        if let key = transformation as? TransformationKey {
            switch key {
            case .compose(let transformations):
                var newTransformation: [PreferenceTransformation] = transformations
                newTransformation.append(transformation2)
                return TransformationKey.compose(transformations: newTransformation)
            default:
                break
            }
        }
        // compose the two transformations
        return TransformationKey.compose(transformations: [transformation, transformation2])
    }

}

extension TransformationKey: Equatable {}

public func == (lhs: TransformationKey, rhs: TransformationKey) -> Bool {
    switch (lhs, rhs) {

    case (let .compose(ts1), let .compose(ts2)):
        if ts1.isEmpty && ts2.isEmpty {
            return true
        }
        return false
    case (let .valueTransformer(t1), let .valueTransformer((t2))):
        return t1 == t2
    case (.archive, .archive):
        return true
    case (.none, .none):
        return true
        /*case (let .ClosureTuple(t1, r1), let .ClosureTuple(t2, r2)):
         return false*/
    default:
        return false
    }
}

public extension PreferencesType {

    public subscript(key: PreferenceKey, closure: (PreferenceObject?) -> Any?) -> Any? {
        return closure(object(forKey: key))
    }

    public subscript(key: PreferenceKey, transformationKey: TransformationKey) -> Any? {
        return transformationKey.get(key, from: self)
    }

    public subscript(key: PreferenceKey, transformation: PreferenceTransformation) -> Any? {
        return transformation.get(key, from: self)
    }

    #if !os(Linux)
    public subscript(key: PreferenceKey, valueTransformer: ValueTransformer) -> PreferenceObject? {
        return valueTransformer.reverseTransformedValue(object(forKey: key))
    }
    #endif
}

public extension MutablePreferencesType {

    public subscript(key: PreferenceKey, transformationKey: TransformationKey) -> Any? {
        get {
            return transformationKey.get(key, from: self)
        }
        set {
            transformationKey.set(key, value: newValue, to: self)
        }
    }

    public subscript(key: PreferenceKey, transformation: PreferenceTransformation) -> Any? {
        get {
            return transformation.get(key, from: self)
        }
        set {
            transformation.set(key, value: newValue, to: self)
        }
    }

    #if !os(Linux)
    public subscript(key: PreferenceKey, valueTransformer: ValueTransformer) -> PreferenceObject? {
        get {
            return valueTransformer.reverseTransformedValue(object(forKey: key))
        }
        set {
            assert(valueTransformer.classForCoder.allowsReverseTransformation()) // don't store not decodable value
            let transformedValue = valueTransformer.transformedValue(newValue)
            if transformedValue == nil {
                removeObject(forKey: key)
            } else {
                set(transformedValue as PreferenceObject?, forKey: key)
            }
        }
    }
    #endif

}

extension PreferenceTransformation {

    public func get<T: Any>(_ key: PreferenceKey, from preferences: PreferencesType) -> T? {
        let value = preferences.object(forKey: key)
        guard let reverted = reverseTransformedValue(value) else {
            return nil
        }
        return reverted as? T
    }

    public func set<T: Any>(_ key: PreferenceKey, value newValue: T?, to preferences: MutablePreferencesType) {
        if  let transformedValue = self.transformedValue(newValue) {
            preferences.set(transformedValue, forKey: key)
        } else {
            preferences.removeObject(forKey: key)
        }
    }

}

extension TransformationKey: PreferenceTransformation {

    public func reverseTransformedValue<T: Any>(_ value: PreferenceObject?) -> T? {
        switch self {
        case .none :
            guard let value = value else {
                return nil
            }
            return value as? T
        case .archive :
            if let data = value as? Data {
                return Prephirences.unarchive(data) as? T
            }
            return nil
        case .valueTransformer(let valueTransformer) :
            guard let reverted = valueTransformer.reverseTransformedValue(value) else {
                return nil
            }
            return reverted as? T
        case .closureTuple(let (_, revert)) :
            guard let reverted = revert(value) else {
                return nil
            }
            return reverted as? T
        case .compose(transformations: let ts):
            if ts.isEmpty {
                guard let value = value else {
                    return nil
                }
                return value as? T
            }
            var currentValue = value
            var slice = ts[ts.indices]
            var tranformation = slice.popFirst()
            while tranformation != nil {
                currentValue = tranformation?.reverseTransformedValue(currentValue)
                tranformation = slice.popFirst()
            }
            guard let safeValue = currentValue else {
                return nil
            }
            return safeValue as? T
        }
    }

    public func transformedValue<T: PreferenceObject>(_ value: T?) -> PreferenceObject? {
        switch self {
        case .none :
            return value // as? PreferenceObject
        case .archive :
            if let archivable = value as? NSCoding {
                return Prephirences.archive(archivable)
            } else {
                return nil
            }
        case .valueTransformer(let valueTransformer) :
            return valueTransformer.transformedValue(value)
        case .closureTuple(let (transform, _)) :
            return transform == nil ? value : transform?(value)
        case .compose(transformations: let ts) :
            if ts.isEmpty {
                return value// as? PreferenceObject
            }
            var currentValue: PreferenceObject? = value
            var slice = ts[ts.indices]
            var tranformation = slice.popLast()
            while tranformation != nil {
                currentValue = tranformation?.transformedValue(currentValue)
                tranformation = slice.popLast()
            }
            return currentValue
        }
    }

}

// MARK: RawRepresentable

extension RawRepresentable where Self.RawValue: PreferenceObject {

    init?(preferenceObject: PreferenceObject?) {
        if let rawValue = preferenceObject as? Self.RawValue {
            self.init(rawValue: rawValue)
        } else {
            return nil
        }
    }

    static func rawValueOf(_ value: Any?) -> PreferenceObject? {
        return (value as? Self)?.rawValue
    }

    // Return a transformation object for prephirences
    public static var preferenceTransformation: PreferenceTransformation {
        return TransformationKey.closureTuple(transform: Self.rawValueOf, revert: Self.init)
    }
}

public extension PreferencesType {

    // Read a RawRepresentable object
    public func rawRepresentable<T: RawRepresentable>(forKey key: PreferenceKey) -> T? {
        if let rawValue = self.object(forKey: key) as? T.RawValue {
            return T(rawValue: rawValue)
        }
        return nil
    }

}

public extension MutablePreferencesType {

    // Store a RawRepresentable object
    public func set<T: RawRepresentable>(rawValue value: T?, forKey key: PreferenceKey) {
        if let rawValue = value?.rawValue {
            self.set(rawValue, forKey: key)
        } else {
            self.removeObject(forKey: key)
        }
    }

}
