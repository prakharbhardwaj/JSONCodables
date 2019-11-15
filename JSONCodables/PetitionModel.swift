//
//  PetitionModel.swift
//  JSONCodables
//
//  Created by Prakhar Prakash Bhardwaj on 15/11/19.
//  Copyright © 2019 Prakhar Prakash Bhardwaj. All rights reserved.
//

import Foundation


// MARK: - Petetion
struct Petetion: Codable {
    let metadata: Metadata
    let results: [Result]
}

// MARK: - Metadata
struct Metadata: Codable {
    let responseInfo: ResponseInfo
    let requestInfo: RequestInfo
    let resultset: Resultset
}

// MARK: - RequestInfo
struct RequestInfo: Codable {
    let apiVersion: Int
    let resource: String
    let query: Query
}

// MARK: - Query
struct Query: Codable {
    let body, createdAfter, createdAt, createdBefore: JSONNull?
    let isPublic: Int
    let isSignable: JSONNull?
    let limit: String
    let mock, offset: Int
    let petitionsDefaultLimit: String
    let publicThreshold: Int
    let responseID, signatureCount, signatureCountCeiling: JSONNull?
    let signatureCountFloor: Int
    let signatureThreshold, signatureThresholdCeiling, signatureThresholdFloor: JSONNull?
    let sortBy, sortOrder: String
    let status, title, url: JSONNull?
    let websiteURL: String

    enum CodingKeys: String, CodingKey {
        case body, createdAfter, createdAt, createdBefore, isPublic, isSignable, limit, mock, offset, petitionsDefaultLimit, publicThreshold
        case responseID = "responseId"
        case signatureCount, signatureCountCeiling, signatureCountFloor, signatureThreshold, signatureThresholdCeiling, signatureThresholdFloor, sortBy, sortOrder, status, title, url
        case websiteURL = "websiteUrl"
    }
}

// MARK: - ResponseInfo
struct ResponseInfo: Codable {
    let status: Int
    let developerMessage, userMessage, errorCode, moreInfo: String
}

// MARK: - Resultset
struct Resultset: Codable {
    let count, limit, offset: Int
}

// MARK: - Result
struct Result: Codable {
    let id: String
    let type: TypeEnum
    let title, body: String
    let petitionType, issues: [Issue]
    let signatureThreshold, signatureCount, signaturesNeeded: Int
    let url: String
    let deadline: Int
    let status: Status
    let response: ResponseUnion
    let created: Int
    let isSignable, isPublic: Bool
    let reachedPublic: Int

    enum CodingKeys: String, CodingKey {
        case id, type, title, body
        case petitionType = "petition_type"
        case issues, signatureThreshold, signatureCount, signaturesNeeded, url, deadline, status, response, created, isSignable, isPublic, reachedPublic
    }
}

// MARK: - Issue
struct Issue: Codable {
    let id: Int
    let name: String
}

enum ResponseUnion: Codable {
    case anythingArray([JSONAny])
    case responseClass(ResponseClass)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([JSONAny].self) {
            self = .anythingArray(x)
            return
        }
        if let x = try? container.decode(ResponseClass.self) {
            self = .responseClass(x)
            return
        }
        throw DecodingError.typeMismatch(ResponseUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ResponseUnion"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .anythingArray(let x):
            try container.encode(x)
        case .responseClass(let x):
            try container.encode(x)
        }
    }
}

// MARK: - ResponseClass
struct ResponseClass: Codable {
    let id: Int
    let url: String
    let associationTime: Int
}

enum Status: String, Codable {
    case closed = "closed"
    case pendingResponse = "pending response"
    case responded = "responded"
}

enum TypeEnum: String, Codable {
    case petition = "petition"
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public func hash(into hasher: inout Hasher) {
        // No-op
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

class JSONCodingKey: CodingKey {
    let key: String

    required init?(intValue: Int) {
        return nil
    }

    required init?(stringValue: String) {
        key = stringValue
    }

    var intValue: Int? {
        return nil
    }

    var stringValue: String {
        return key
    }
}

class JSONAny: Codable {

    let value: Any

    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
        return DecodingError.typeMismatch(JSONAny.self, context)
    }

    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
        return EncodingError.invalidValue(value, context)
    }

    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if container.decodeNil() {
            return JSONNull()
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if let value = try? container.decodeNil() {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer() {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
        if let value = try? container.decode(Bool.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeNil(forKey: key) {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
        var arr: [Any] = []
        while !container.isAtEnd {
            let value = try decode(from: &container)
            arr.append(value)
        }
        return arr
    }

    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
        var dict = [String: Any]()
        for key in container.allKeys {
            let value = try decode(from: &container, forKey: key)
            dict[key.stringValue] = value
        }
        return dict
    }

    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
        for value in array {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer()
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let key = JSONCodingKey(stringValue: key)!
            if let value = value as? Bool {
                try container.encode(value, forKey: key)
            } else if let value = value as? Int64 {
                try container.encode(value, forKey: key)
            } else if let value = value as? Double {
                try container.encode(value, forKey: key)
            } else if let value = value as? String {
                try container.encode(value, forKey: key)
            } else if value is JSONNull {
                try container.encodeNil(forKey: key)
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer(forKey: key)
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int64 {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if value is JSONNull {
            try container.encodeNil()
        } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
        }
    }

    public required init(from decoder: Decoder) throws {
        if var arrayContainer = try? decoder.unkeyedContainer() {
            self.value = try JSONAny.decodeArray(from: &arrayContainer)
        } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
            self.value = try JSONAny.decodeDictionary(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            self.value = try JSONAny.decode(from: container)
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let arr = self.value as? [Any] {
            var container = encoder.unkeyedContainer()
            try JSONAny.encode(to: &container, array: arr)
        } else if let dict = self.value as? [String: Any] {
            var container = encoder.container(keyedBy: JSONCodingKey.self)
            try JSONAny.encode(to: &container, dictionary: dict)
        } else {
            var container = encoder.singleValueContainer()
            try JSONAny.encode(to: &container, value: self.value)
        }
    }
}


/*
struct Petitions: Codable {
    var results: [Petition]
}

struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
} */


