//
//  VersionedCodable+encode.swift
//  
//
//  Created by Jonathan Rothwell on 29/04/2023.
//

import Foundation

extension VersionedCodable {
    /// Returns an encoded representation of `self`, with a `version` field that
    /// matches the current version of its type, delegating the encoding to the `encode` function
    /// you provide.
    ///
    ///
    /// - Warning: We always encode the requested version of the type, with the most recent `version`
    ///   value. If you must encode an older version, then encode that type directly: don't try to add a
    ///   `version` property to your type & try to modify that. This will result in a
    ///   ``VersionedEncodingError/typeHasClashingVersionField``.
    /// - Parameter using: The value to encode as a property list. Must conform to
    ///   ``VersionedCodable`` and thus supply a ``VersionedCodable/version`` value.
    /// - Returns: `self`, encoded by the `encode` parameter.
    public func encodeTransparently(using encode: (Encodable) throws -> Data) rethrows -> Data {
        try encode(VersionedCodableWritingWrapper(wrapped: self, spec: VersionPathSpecification.self))
    }
}
