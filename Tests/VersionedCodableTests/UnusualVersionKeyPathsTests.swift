//
//  UnusualPathToVersionFieldTests.swift
//  
//
//  Created by Jonathan Rothwell on 23/01/2024.
//

import Testing
import Foundation
@testable import VersionedCodable

/// Tests unusual paths to the version field in VersionedCodable.
@Suite("Custom version KeyPaths", .tags(.behaviour))
struct UnusualVersionKeyPathsTests {
    @Test("decodes a `_version` field at the root of the type with a simple spec")
    func fieldAtRootWithSimpleName() throws {
        let data = try Data(
            contentsOf: Bundle.module.url(forResource: "sonnet-v1",
                                          withExtension: "json")!)
        let decoded = try JSONDecoder().decode(versioned: SonnetV1.self, from: data)
        #expect("William Shakespeare" == decoded.author)
    }
    
    @Test("decodes a version field nested further inside a `metadata` key")
    func fieldWithMoreComplexPath() throws {
        let data = try Data(
            contentsOf: Bundle.module.url(forResource: "sonnet-v2",
                                          withExtension: "json")!)
        let decoded = try JSONDecoder().decode(versioned: SonnetV2.self, from: data)
        #expect("William Shakespeare" == decoded.author)
    }

}
