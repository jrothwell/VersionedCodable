//
//  NothingEarlier.swift
//  
//
//  Created by Jonathan Rothwell on 15/04/2023.
//

import Foundation

/// The type to set as  `PreviousVersion` for a ``VersionedCodable`` type which does **not**
/// have any older versions.
///
/// - Warning: Don't decode or encode this type. It's just here to make the compiler work. The
///   behaviour on decoding and encoding is undefined and may result in a crash.
public enum NothingEarlier {}

extension VersionedCodable where PreviousVersion == NothingEarlier {
    // For the oldest type, this avoids people having to declare a useless
    // initializer from `NothingEarlier`.
    
    /// - Warning: Do not invoke this initializer. The behaviour on initialization is undefined: in future it
    ///   may result in an unrecoverable fatal error or assertion failure.
    public init(from: NothingEarlier) throws {
        throw VersionedDecodingError.unsupportedVersion(tried: Self.self)
    }
}

extension NothingEarlier: VersionedCodable {
    public typealias PreviousVersion = NothingEarlier
    public static let version: Int? = nil
    
    
    /// - Warning: Do not invoke this initializer. The behaviour on initialization is undefined: in future it
    ///   may result in an unrecoverable fatal error or assertion failure.
    public init(from decoder: Decoder) throws {
        throw VersionedDecodingError.unsupportedVersion(tried: Self.self)
    }
        
    /// - Warning: Do not try to encode this type. The behaviour on encoding is undefined: in future it
    ///   may result in an unrecoverable fatal error or assertion failure.
    public func encode(to encoder: Encoder) throws {
        throw VersionedDecodingError.unsupportedVersion(tried: Self.self)
    }
}

