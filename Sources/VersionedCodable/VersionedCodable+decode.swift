//
//  VersionedCodable+decode.swift
//  
//
//  Created by Jonathan Rothwell on 29/04/2023.
//

import Foundation

extension VersionedCodable {
    
    /// Returns a value of the type you specify, where the type is versioned, delegating the
    /// decoding to `decode` function you provide. It  will try and find a version of the type that
    /// matches the version (if any) encoded in the data and transparently decode it.
    /// - Parameters:
    ///   - data: The data to decode. Will be passed to `decode`.
    ///   - decode: A function capable of decoding a `Decodable` type from `data`.
    /// - Returns: A value of the specified type, if the `decode` function can parse the data.
    /// - Warning: The return type of `decode` is **not** constrained to the expected
    ///   type (as provided as its first parameter.) Returning a type which cannot be downcast
    ///   to the expected type has undefined behaviour and will result in a crash.
    public static func decodeTransparently<ExpectedType: VersionedCodable>(
        from data: Data,
        using decode: ((Decodable.Type, Data) throws -> Decodable)
    ) throws -> ExpectedType {
        let documentVersion = (try decode(VersionedDocument.self, data) as? VersionedDocument)?.version
        return try decodeTransparently(targetVersion: documentVersion,
                                       from: data,
                                       using: decode)
    }
    
    private static func decodeTransparently<ExpectedType: VersionedCodable>(
        targetVersion: Int?,
        from data: Data,
        using decode: ((Decodable.Type, Data) throws -> Decodable)
    ) throws -> ExpectedType {
        if targetVersion == Self.version {
            return try decode(Self.self, data) as! ExpectedType
        } else if Self.PreviousVersion.self == NothingEarlier.self {
            throw VersionedDecodingError.unsupportedVersion(tried: Self.self)
        } else {
            return try ExpectedType(
                from: Self.PreviousVersion.decodeTransparently(
                    targetVersion: targetVersion,
                    from: data,
                    using: decode))
        }

    }
}
