//
//  VersionedCodablePerformanceTests.swift
//  
//
//  Created by Jonathan Rothwell on 30/04/2023.
//

import XCTest

final class VersionedCodablePerformanceTests: XCTestCase {

    func testDecodingPerformance() throws {
        let decoder = JSONDecoder()
        
        self.measure {
            try! PerformanceTestDocument
                .threeHundredLoremIpsumVersionOneDocuments
                .forEach {
                    _ = try decoder.decode(
                        versioned: PerformanceTestDocument.self,
                        from: $0)
            }
        }
    }

}
