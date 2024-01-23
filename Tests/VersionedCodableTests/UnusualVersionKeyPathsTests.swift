//
//  UnusualPathToVersionFieldTests.swift
//  
//
//  Created by Jonathan Rothwell on 23/01/2024.
//

import XCTest
@testable import VersionedCodable

/// Tests unusual paths to the version field in VersionedCodable.
final class UnusualVersionKeyPathsTests: XCTestCase {


    func testFieldAtRootWithSimpleName() throws {
        let data = try Data(
            contentsOf: Bundle.module.url(forResource: "sonnet-v1",
                                          withExtension: "json")!)
        let decoded = try JSONDecoder().decode(versioned: SonnetV1.self, from: data)
        XCTAssertEqual("William Shakespeare", decoded.author)
    }
    
    func testFieldWithMoreComplexPath() throws {
        let data = try Data(
            contentsOf: Bundle.module.url(forResource: "sonnet-v2",
                                          withExtension: "json")!)
        let decoded = try JSONDecoder().decode(versioned: SonnetV2.self, from: data)
        XCTAssertEqual("William Shakespeare", decoded.author)
    }


    func testExplodesWhenEncodingTypeWithClashingVersionField() throws {
        let clashingSonnet = SonnetWithClash(metadata: .init(version: "First Version"))
        
        XCTAssertThrowsError(try JSONEncoder().encode(versioned: clashingSonnet)) { error in
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
