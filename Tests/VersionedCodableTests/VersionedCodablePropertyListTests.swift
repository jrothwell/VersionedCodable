//
//  VersionedCodablePropertyListTests.swift
//  
//
//  Created by Jonathan Rothwell on 18/04/2023.
//

import Testing
import Foundation
@testable import VersionedCodable

@Suite("Property lists", .tags(.behaviour)) struct VersionedCodablePropertyListTests {

    @Test("A Codable encodes into a property list")
    func encoding() throws {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        // XML makes our life a bit easier because it's human-readable,
        // unlike binary property lists.

        let expected = try Data(
            contentsOf: Bundle.module.url(forResource: "expectedEncoded",
                                          withExtension: "plist")!)
        let data = try encoder.encode(versioned: poemForEncoding)
        #expect(String(data: expected, encoding: .utf8)! ==
                       String(data: data, encoding: .utf8)!)
    }
    
    @Test("current version decodes correctly")
    func decodingCurrentVersion() throws {
        let data = try Data(
            contentsOf: Bundle.module.url(forResource: "expectedEncoded",
                                          withExtension: "plist")!)
        let decoded = try PropertyListDecoder()
            .decode(versioned: Poem.self, from: data)
        #expect("William Topaz McGonagall" == decoded.author?.name)
    }
    
    @Test("older version decodes correctly")
    func decodingOldVersion() throws {
        let data = try Data(
            contentsOf: Bundle.module.url(forResource: "expectedOlder",
                                          withExtension: "plist")!)
        let decoded = try PropertyListDecoder()
            .decode(versioned: Poem.self, from: data)
        #expect("William Topaz McGonagall" == decoded.author?.name)
        #expect(examplePoem == decoded.lines)
    }

    @Test("throws when decoding unsupported version")
    func decodingUnsupportedVersion() throws {
        let data = try Data(
            contentsOf: Bundle.module.url(forResource: "expectedUnsupported",
                                          withExtension: "plist")!)
        #expect(throws:
                    VersionedDecodingError.unsupportedVersion(tried: Poem.PoemPreV1.self)) {
            try PropertyListDecoder().decode(versioned: Poem.self, from: data)
        }
    }
    

}
