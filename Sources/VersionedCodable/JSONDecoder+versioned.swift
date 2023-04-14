import Foundation

extension JSONDecoder {
    public func decode<ExpectedType: VersionedCodable>(
        versioned expectedType: ExpectedType.Type,
        from data: Data) throws -> ExpectedType {
        let documentVersion = try self.decode(VersionedDocument.self,
                                      from: data).version
        
        if documentVersion == expectedType.thisVersion {
            // This is the right version, we can decode it
            return try decode(expectedType.self, from: data)
        } else if expectedType.PreviousVersion == NothingEarlier.self {
            throw VersionedDecodingError.olderThanOldestVersion(
                desiredVersion: documentVersion,
                ourMinimum: expectedType.thisVersion)
        } else {
            return try ExpectedType(
                from: decode(
                    versioned: expectedType.PreviousVersion,
                    from: data))
        }
    }
}
