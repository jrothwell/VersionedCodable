import Foundation

extension JSONDecoder {
    
    
    /// Returns a value of the type you specify, decoded from a JSON object, **where** the type is
    /// versioned. It will try and find a version of the type that matches the version (if any) encoded
    /// in the JSON object.
    ///
    /// This behaves in the same way as ``decode(_:from:)`` but also throws the
    /// ``VersionedDecodingError/olderThanOldestVersion(desiredVersion:ourMinimum:)``
    /// error if there are no versions of the type where their `thisVersion` matches what's in (or not in) `data`.
    ///
    /// - Parameters:
    ///   - expectedType: The type of the value to decode from the supplied JSON object—
    ///     which may be an older version.
    ///   - data: The JSON object to decode.
    /// - Returns: A value of the specified type, if the decoder can parse the data.
    public func decode<ExpectedType: VersionedCodable>(
        versioned expectedType: ExpectedType.Type,
        from data: Data) throws -> ExpectedType {
        let documentVersion = try self.decode(VersionedDocument.self,
                                      from: data).version
        
        if documentVersion == expectedType.thisVersion {
            // This is the right version, we can decode it
            return try decode(expectedType.self, from: data)
        } else if expectedType.PreviousVersion == NothingEarlier.self {
            throw VersionedDecodingError.noOlderVersionAvailable(than: expectedType.self)
        } else {
            return try ExpectedType(
                from: decode(
                    versioned: expectedType.PreviousVersion,
                    from: data))
        }
    }
}
