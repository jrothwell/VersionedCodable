//
//  VersionedCodablePropertyListTests.swift
//  
//
//  Created by Jonathan Rothwell on 18/04/2023.
//

import XCTest
import VersionedCodable

final class VersionedCodablePropertyListTests: XCTestCase {

    func testEncoding() throws {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        // XML makes our life a bit easier because it's human-readable,
        // unlike binary property lists.

        let expected = try Data(
            contentsOf: Bundle.module.url(forResource: "expectedEncoded",
                                          withExtension: "plist")!)
        let data = try encoder.encode(versioned: poemForEncoding)
        XCTAssertEqual(String(data: expected, encoding: .utf8)!,
                       String(data: data, encoding: .utf8)!)
    }
    
    func testDecodingCurrentVersion() throws {
        let data = try Data(
            contentsOf: Bundle.module.url(forResource: "expectedEncoded",
                                          withExtension: "plist")!)
        let decoded = try PropertyListDecoder()
            .decode(versioned: Poem.self, from: data)
        XCTAssertEqual("William Topaz McGonagall", decoded.author?.name)
    }
    
    func testDecodingOldVersion() throws {
        let data = try Data(
            contentsOf: Bundle.module.url(forResource: "expectedOlder",
                                          withExtension: "plist")!)
        let decoded = try PropertyListDecoder()
            .decode(versioned: Poem.self, from: data)
        XCTAssertEqual("William Topaz McGonagall", decoded.author?.name)
        XCTAssertEqual(examplePoem, decoded.lines)
    }

    func testDecodingUnsupportedVersion() throws {
        let data = try Data(
            contentsOf: Bundle.module.url(forResource: "expectedUnsupported",
                                          withExtension: "plist")!)
        XCTAssertThrowsError(try PropertyListDecoder()
            .decode(versioned: Poem.self, from: data)) { error in
                switch error {
                case VersionedDecodingError.unsupportedVersion(let lastTriedVersion):
                    XCTAssertTrue(lastTriedVersion == Poem.PoemPreV1.self)
                default:
                    XCTFail("An error threw, but it was the wrong kind of error (expected `VersionedDecodingError.noOlderVersionAvailable`, got: `\(error)`)")
                }
            }
    }
    
    func testExplodesWhenEncodingTypeWithClashingVersionField() throws {
        let clashingPoem = PoemWithClash(
            content: "Though the great Waters sleep",
            version: 2)
        
        XCTAssertThrowsError(try PropertyListEncoder().encode(versioned: clashingPoem)) { error in
            switch error {
            case VersionedEncodingError.typeHasClashingVersionField:
                // ok
                break
            default:
                XCTFail("An error threw, but it was the wrong kind of error (expected `VersionedEncodingError.typeHasClashingVersionField`, got: \(error)")
            }
        }
    }


}
