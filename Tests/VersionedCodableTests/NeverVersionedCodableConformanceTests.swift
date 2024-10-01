//
//  NeverVersionedCodableConformanceTests.swift
//  VersionedCodable
//
//  Created by Jonathan Rothwell on 01/10/2024.
//

import Foundation
import Testing
@testable import VersionedCodable


@available(macOS 14.0, iOS 17.0, *)
@Test("`Never` won't decode using the `VersionedCodable` decoding method", .tags(.configuration))
func neverDoesntDecode() async throws {    
    let neverJSON = Data(#"{"no": "no"}"#.utf8)
    #expect {
        try JSONDecoder().decode(versioned: Never.self, from: neverJSON)
    } throws: { error in
        isTypeMismatch(error, vs: Never.self)
    }
            
}
