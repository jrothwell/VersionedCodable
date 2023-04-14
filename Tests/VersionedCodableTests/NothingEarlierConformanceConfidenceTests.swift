//
//  NothingEarlierConformanceConfidenceTests.swift
//  
//
//  Created by Jonathan Rothwell on 15/04/2023.
//

import XCTest
import VersionedCodable

final class NothingEarlierConformanceConfidenceTests: XCTestCase {
    
    func testNeverAsVersionedCodableBehavesHowWeExpect() throws {
        XCTAssertNil(NothingEarlier.thisVersion)
    }

}
