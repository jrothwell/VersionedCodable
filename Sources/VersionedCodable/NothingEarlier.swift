//
//  NothingEarlier.swift
//  
//
//  Created by Jonathan Rothwell on 15/04/2023.
//

import Foundation

/// The type to set as  `PreviousVersion` for a `VersionedDecodable` type which does **not**
/// have any older versions.
///
/// - Warning: Don't initialize this type. It's just here to make the compiler work. The behaviour on
///   initialization is undefined.
public enum NothingEarlier {}

extension NothingEarlier: VersionedCodable {
    public typealias PreviousVersion = NothingEarlier
    public static let thisVersion: Int? = nil
    
    public init(from decoder: Decoder) throws {
        throw VersionedDecodingError.unsupportedVersion(tried: Self.self)
    }
        
    public init(from: NothingEarlier) throws {
        throw VersionedDecodingError.unsupportedVersion(tried: Self.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        throw VersionedDecodingError.unsupportedVersion(tried: Self.self)
    }
}


extension VersionedCodable where PreviousVersion == NothingEarlier {
    public init(from: NothingEarlier) throws {
        throw VersionedDecodingError.unsupportedVersion(tried: Self.self)
    }
}
