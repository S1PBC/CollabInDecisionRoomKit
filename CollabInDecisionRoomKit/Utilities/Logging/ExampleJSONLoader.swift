//
//  ExampleJSONLoader.swift
//  BREVA
//
//  Created by AidanCarrier on 12/11/25.
//
//
//import Foundation
//
//public nonisolated enum JSONLoaderError: Error, CustomStringConvertible {
//    case fileNotFound(resource: String, ext: String)
//    case unreadableData(underlying: Error)
//    case decodingFailed(expectedType: String, underlying: Error)
//    case topLevelNotObject(expected: String)
//
//    public var description: String {
//        switch self {
//        case let .fileNotFound(resource, ext):
//            return "Could not find \(resource).\(ext) in the specified Bundle."
//        case let .unreadableData(underlying):
//            return "Failed to read data from file. Underlying error: \(underlying)"
//        case let .decodingFailed(expectedType, underlying):
//            return "JSON decoding failed for expected type \(expectedType). Underlying error: \(underlying)"
//        case let .topLevelNotObject(expected):
//            return "Top-level JSON is not an object. Expected \(expected)."
//        }
//    }
//}
//
//public nonisolated enum JSONValue: Decodable, Equatable {
//    case object([String: JSONValue])
//    case array([JSONValue])
//    case string(String)
//    /// - note: JSON has only one numeric, I have chosen to use Double as the numeric type because I'd expect values passed into the JSON to not need a high level of precision, if this is no longer the case, change this to Float.
//    case number(Double)
//    case bool(Bool)
//    case null
//
//    public init(from decoder: Decoder) throws {
//        // Try keyed (object)
//        if let container = try? decoder.container(keyedBy: DynamicCodingKeys.self) {
//            var dict: [String: JSONValue] = [:]
//            for key in container.allKeys {
//                dict[key.stringValue] = try container.decode(JSONValue.self, forKey: key)
//            }
//            self = .object(dict)
//            return
//        }
//        // Try unkeyed (array)
//        if var arrayContainer = try? decoder.unkeyedContainer() {
//            var arr: [JSONValue] = []
//            while !arrayContainer.isAtEnd {
//                let value = try arrayContainer.decode(JSONValue.self)
//                arr.append(value)
//            }
//            self = .array(arr)
//            return
//        }
//        // Try single value
//        let single = try decoder.singleValueContainer()
//        if single.decodeNil() {
//            self = .null
//        } else if let b = try? single.decode(Bool.self) {
//            self = .bool(b)
//        } else if let n = try? single.decode(Double.self) {
//            self = .number(n)
//        } else if let s = try? single.decode(String.self) {
//            self = .string(s)
//        } else {
//            throw JSONLoaderError.decodingFailed(expectedType: "JSONValue", underlying: DecodingError.typeMismatch(
//                JSONValue.self,
//                .init(codingPath: decoder.codingPath, debugDescription: "Unsupported JSON token")
//            ))
//        }
//    }
//
//    private struct DynamicCodingKeys: CodingKey {
//        var stringValue: String
//        init?(stringValue: String) { self.stringValue = stringValue }
//        var intValue: Int? { nil }
//        init?(intValue: Int) { nil }
//    }
//}
//
///// A JSON value, which can either be a dictionary, an array, a boolean, an int, or a numeric, in this case double.
//public extension JSONValue {
//    nonisolated var dictionary: [String: JSONValue]? {
//        if case let .object(d) = self { return d } else { return nil }
//    }
//    nonisolated var array: [JSONValue]? {
//        if case let .array(a) = self { return a } else { return nil }
//    }
//    nonisolated var string: String? {
//        if case let .string(s) = self { return s } else { return nil }
//    }
//    nonisolated var bool: Bool? {
//        if case let .bool(b) = self { return b } else { return nil }
//    }
//    nonisolated var double: Double? {
//        if case let .number(n) = self { return n } else { return nil }
//    }
//    nonisolated var int: Int? {
//        if case let .number(n) = self, n.rounded(.towardZero) == n { return Int(n) } else { return nil }
//    }
//    subscript(key: String) -> JSONValue? {
//        dictionary?[key]
//    }
//    subscript(index: Int) -> JSONValue? {
//        array?[index]
//    }
//}
//
///// Generic typed function to load a homogenous dictionary from the bundle with the given resource name and generic type,, throwing a ``JSONLoaderError`` on failure
//@inlinable
//nonisolated public func loadJSON<T: Decodable>(
//    resourceName: String,
//    withExtension: String = "json",
//    bundle: Bundle = .main
//) throws -> T {
//    guard let url = bundle.url(forResource: resourceName, withExtension: withExtension) else {
//        throw JSONLoaderError.fileNotFound(resource: resourceName, ext: withExtension)
//    }
//    let data: Data
//    do {
//        data = try Data(contentsOf: url, options: [.mappedIfSafe])
//    } catch {
//        throw JSONLoaderError.unreadableData(underlying: error)
//    }
//    do {
//        let decoder = JSONDecoder()
//        return try decoder.decode(T.self, from: data)
//    } catch {
//        throw JSONLoaderError.decodingFailed(expectedType: String(describing: T.self), underlying: error)
//    }
//}
//
///// Generic typed function to load a homogenous dictionary from the bundle with the given resource name and generic type, , throwing a ``JSONLoaderError`` on failure
//nonisolated public func loadJSONDictionary<T: Decodable>(
//    resourceName: String,
//    withExtension: String = "json",
//    bundle: Bundle = .main
//) throws -> [String: T] {
//    try loadJSON(resourceName: resourceName, withExtension: withExtension, bundle: bundle)
//}
//
///// Function to load a heterogenous dictionary from the bundle with the given resource name, where each value is a ``JSONValue``, throwing a ``JSONLoaderError`` on failure
//nonisolated public func loadJSONHeterogeneousDictionary(
//    resourceName: String,
//    withExtension: String = "json",
//    bundle: Bundle = .main
//) throws -> [String: JSONValue] {
//    let root: JSONValue = try loadJSON(resourceName: resourceName, withExtension: withExtension, bundle: bundle)
//    guard let dict = root.dictionary else {
//        throw JSONLoaderError.topLevelNotObject(expected: "[String: JSONValue]")
//    }
//    return dict
//}
//
///// Function to load a heterogenous dictionary as a [String: Any] dictionary.
///// - Note: Must use `as?` for each value accessed from this dictionary. Possibility of this function silently throwing.
//public func loadJSONAnyDictionary(
//    resourceName: String,
//    withExtension: String = "json"
//) throws -> Dictionary<String, Any> {
//    guard
//        let url = Bundle.main.url(
//            forResource: resourceName,
//            withExtension: withExtension
//        )
//    else {
//        throw NSError(
//            domain: "Couldn't find: \(resourceName).\(withExtension) in Bundle",
//            code: -1
//        )
//
//    }
//    do {
//        let data = try Data(contentsOf: url)
//        let jsonObject = try JSONSerialization.jsonObject(
//            with: data,
//            options: []
//        )
//        if let dictionary = jsonObject as? [String: Any] {
//            return dictionary
//        } else {
//            throw NSError(domain: "JSON is not a dictionary.", code: -1)
//        }
//    } catch {
//        throw error
//    }
//}
