//
//  JSONEncoder+versioned.swift
//  
//
//  Created by Jonathan Rothwell on 14/04/2023.
//

import Foundation

extension JSONEncoder {
    /// Returns a JSON-encoded representation of the value you supply, with a `version` field that matches
    /// the current version of its type.
    ///
    /// This behaves identically to `encode(_:)`  except it adds a
    /// `version` attribute at the root with the version in your type's ``VersionedCodable/version``.
    ///
    /// - Warning: We always encode the requested version of the type, with the most recent `version`
    ///   value. If you must encode an older version, then encode that type directly: don't try to add a
    ///   `version` property to your type & try to modify that. The behaviour if you do so is undefined.
    /// - Parameter value: The value to encode as a property list. Must conform to
    ///   ``VersionedCodable`` and thus supply a ``VersionedCodable/version`` value.
    /// - Returns: The encoded JSON data, complete with a `version` field.
    public func encode(versioned value: any VersionedCodable) throws -> Foundation.Data {
        try value.encodeTransparently { try self.encode($0) }
    }
}
