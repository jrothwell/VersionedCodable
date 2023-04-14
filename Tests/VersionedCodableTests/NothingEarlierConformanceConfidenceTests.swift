//
//  NothingEarlierConformanceConfidenceTests.swift
//  
//
//  Created by Jonathan Rothwell on 15/04/2023.
//

import XCTest
import VersionedCodable

final class NothingEarlierConformanceConfidenceTests: XCTestCase {
    
    func testNothingEarlierVersionIsNil() throws {
        XCTAssertNil(NothingEarlier.thisVersion)
    }
    
    func testDecodingThrowsError() throws {
        do {
            _ = try JSONDecoder().decode(NothingEarlier.self, from: "{}".data(using: .utf8)!)
        } catch VersionedDecodingError.noOlderVersionAvailable {
            // ok
        } catch {
            XCTFail("Got the wrong error. Was expecting a `VersionedDecodingError`, got: \(error.localizedDescription)")
        }
    }
}
