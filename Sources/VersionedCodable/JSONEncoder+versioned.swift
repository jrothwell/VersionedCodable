//
//  File.swift
//  
//
//  Created by Jonathan Rothwell on 14/04/2023.
//

import Foundation

extension JSONEncoder {
    public func encode(versioned value: any VersionedCodable) throws -> Foundation.Data {
        try encode(VersionedCodableWritingWrapper(wrapped: value))
    }
}

private struct VersionedCodableWritingWrapper: Encodable {
    var wrapped: any VersionedCodable
    
    public func encode(to encoder: Encoder) throws {
        try wrapped.encode(to: encoder)
        try VersionedDocument(version: type(of: wrapped).thisVersion).encode(to: encoder)
    }
}
