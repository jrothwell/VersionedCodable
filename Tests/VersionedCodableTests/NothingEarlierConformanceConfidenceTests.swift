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
        XCTAssertNil(NothingEarlier.thisVersion)
    }
    
    func testDecodingThrowsError() throws {
        XCTAssertThrowsError(try JSONDecoder().decode(NothingEarlier.self, from: blankData)) { error in
            XCTAssertEqual(VersionedDecodingError.noOlderVersionAvailable, error as? VersionedDecodingError)
        }
        
    }
    
    func testDecodingFromSlightlyEarlierType() throws {
        XCTAssertThrowsError(try JSONDecoder().decode(versioned: VersionedCodableWithoutOlderVersion.self, from: blankData)) { error in
            XCTAssertEqual(VersionedDecodingError.olderThanOldestVersion(desiredVersion: nil, ourMinimum: 1), error as? VersionedDecodingError)
        }
    }
}

struct VersionedCodableWithoutOlderVersion: VersionedCodable {
    static let thisVersion: Int? = 1
    
    typealias PreviousVersion = NothingEarlier
    
    var text: String
}
