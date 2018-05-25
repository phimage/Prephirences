//
//  PrephirenceType+Codable.swift
//  Prephirences
//
//  Created by Eric Marchand on 25/05/2018.
//  Copyright © 2018 phimage. All rights reserved.
//

import Foundation

extension Prephirences {
    public static var jsonDecoder = JSONDecoder()
    public static var jsonEncoder = JSONEncoder()
}

extension PreferencesType {

    public func decodable<T: Decodable>(_ type: T.Type, forKey key: PreferenceKey, decoder: JSONDecoder = Prephirences.jsonDecoder) throws -> T? {
        guard let data = data(forKey: key) else {
            return nil
        }
        return try decoder.decode(T.self, from: data)
    }

}

extension MutablePreferencesType {

    public func set<T: Encodable>(encodable value: T?, forKey key: PreferenceKey, encoder: JSONEncoder = Prephirences.jsonEncoder) throws {
        if let value = value {
            let data: Data = try encoder.encode(value)
            set(data, forKey: key)
        } else {
            removeObject(forKey: key)
        }
    }

}
