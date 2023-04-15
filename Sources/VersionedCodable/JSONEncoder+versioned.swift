//
//  File.swift
//  
//
//  Created by Jonathan Rothwell on 14/04/2023.
//

import Foundation

extension JSONEncoder {
    /// Returns a JSON-encoded representation of the value you supply, with a `version` field that matches
    /// the current version of its type.
    ///
    /// This behaves identically to ``JSONEncoder/encode(_:)`` except it adds (and potentially overwrites)
    /// a `version` attribute at the root with the version in your type's ``VersionedCodable/thisVersion``.
    /// - Parameter value: The value to encode as JSON.
    ///   Must conform to ``VersionedCodable`` and thus supply a ``VersionedCodable/thisVersion`` value.
    /// - Returns: The encoded JSON data, complete with a `version` field.
    public func encode(versioned value: any VersionedCodable) throws -> Foundation.Data {
        try encode(VersionedCodableWritingWrapper(wrapped: value))
    }
}

private struct VersionedCodableWritingWrapper: Encodable {
    var wrapped: any VersionedCodable
    
    public func encode(to encoder: Encoder) throws {
        try wrapped.encode(to: encoder)
        try VersionedDocument(version: type(of: wrapped).thisVersion).encode(to: encoder)
    }
}
