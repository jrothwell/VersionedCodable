//
//  PropertyListEncoder+versioned.swift
//  
//
//  Created by Jonathan Rothwell on 18/04/2023.
//

import Foundation

extension PropertyListEncoder {
    /// Returns a property list that represents an encoded version of the value you supply, with a
    /// `version` field that matches the current version of its type.
    ///
    /// This behaves identically to ``PropertyListEncoder/encode(_:)`` except it adds (and
    /// potentially overwrites) a `version` attribute at the root with the version in your type's
    /// ``VersionedCodable/thisVersion``.
    /// - Parameter value: The value to encode as a property list.
    ///   Must conform to ``VersionedCodable`` and thus supply a
    ///   ``VersionedCodable/thisVersion`` value.
    /// - Returns: The encoded property list, complete with a `version` field.
    public func encode(versioned value: any VersionedCodable) throws -> Foundation.Data {
        try encode(VersionedCodableWritingWrapper(wrapped: value))
    }
}
