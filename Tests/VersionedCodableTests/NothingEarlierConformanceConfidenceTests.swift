//
//  NothingEarlierConformanceConfidenceTests.swift
//  
//
//  Created by Jonathan Rothwell on 15/04/2023.
//

import XCTest
import VersionedCodable

final class NothingEarlierConformanceConfidenceTests: XCTestCase {
    
    let blankData = "{}".data(using: .utf8)!
    
    func testNothingEarlierVersionIsNil() throws {
        XCTAssertNil(NothingEarlier.version)
    }
    
    func testDecodingThrowsError() throws {
        XCTAssertThrowsError(try JSONDecoder().decode(NothingEarlier.self, from: blankData)) { error in
            switch error {
            case DecodingError.typeMismatch(let type, _):
                XCTAssertTrue(type == NothingEarlier.self)
            default:
                XCTFail("An error threw, but it was the wrong kind of error (expected `VersionedDecodingError.unsupportedVersion(tried:)`, got: \(error)")
            }

        }
        
    }
    
    func testDecodingFromSlightlyEarlierType() throws {
        XCTAssertThrowsError(try JSONDecoder().decode(versioned: VersionedCodableWithoutOlderVersion.self, from: blankData)) { error in
            switch error {
            case VersionedDecodingError.unsupportedVersion(let currentVersion):
                XCTAssertTrue(currentVersion == VersionedCodableWithoutOlderVersion.self)
            default:
                XCTFail("An error threw, but it was the wrong kind of error (expected `VersionedDecodingError.unsupportedVersion(tried:)`, got: \(error)")
            }
        }
    }
}

struct VersionedCodableWithoutOlderVersion: VersionedCodable {
    static let version: Int? = 1
    
    typealias PreviousVersion = NothingEarlier
    
    var text: String
}
