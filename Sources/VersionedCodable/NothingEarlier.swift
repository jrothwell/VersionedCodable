//
//  NothingEarlier.swift
//  
//
//  Created by Jonathan Rothwell on 15/04/2023.
//

import Foundation

/// The type to set as  `PreviousVersion` for a `VersionedDecodable`
/// type which does **not** have any older versions.
public enum NothingEarlier {}

extension NothingEarlier: VersionedCodable {
    public typealias PreviousVersion = NothingEarlier
        
    public static var thisVersion: Int? {
        nil
    }
    
    public init(from decoder: Decoder) throws {
        throw VersionedDecodingError.noOlderVersionAvailable
    }
        
    public init(from: NothingEarlier) throws {
        throw VersionedDecodingError.noOlderVersionAvailable
    }
    
    public func encode(to encoder: Encoder) throws {
        throw VersionedDecodingError.noOlderVersionAvailable
    }
}


extension VersionedCodable where PreviousVersion == NothingEarlier {
    public init(from: NothingEarlier) throws {
        throw VersionedDecodingError.noOlderVersionAvailable
    }
}
