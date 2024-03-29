import Foundation

extension JSONDecoder {
    
    
    /// Returns a value of the type you specify, decoded from a JSON object, **where** the type is
    /// versioned. It will try and find a version of the type that matches the version (if any) encoded
    /// in the JSON object.
    ///
    /// This behaves in the same way as `decode(_:from:)` but also throws the
    /// ``VersionedDecodingError/unsupportedVersion(tried:)`` error if there are no
    /// versions of the type where their `version` matches what's in (or not in) `data`.
    ///
    /// - Parameters:
    ///   - expectedType: The type of the value to decode from the supplied JSON object—
    ///     which may be an older version. Must conform to ``VersionedCodable/VersionedCodable``.
    ///   - data: The JSON object to decode.
    /// - Returns: A value of the specified type, if the decoder can parse the data.
    public func decode<ExpectedType: VersionedCodable>(
        versioned expectedType: ExpectedType.Type,
        from data: Data) throws -> ExpectedType {
            try ExpectedType.decodeTransparently(from: data,
                                    using: { try self.decode($0, from: $1) })
    }
}
