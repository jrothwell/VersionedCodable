//
//  VersionedCodable+encode.swift
//  
//
//  Created by Jonathan Rothwell on 29/04/2023.
//

import Foundation

extension VersionedCodable {
    func encodeTransparently(using encode: (Encodable) throws -> Data) rethrows -> Data {
        try encode(VersionedCodableWritingWrapper(wrapped: self))
    }
}
