//
//  NothingEarlier.swift
//  
//
//  Created by Jonathan Rothwell on 15/04/2023.
//

import Foundation

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
