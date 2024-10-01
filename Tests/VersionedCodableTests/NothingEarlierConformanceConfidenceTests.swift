//
//  NothingEarlierConformanceConfidenceTests.swift
//  
//
//  Created by Jonathan Rothwell on 15/04/2023.
//

import Foundation
import Testing
@testable import VersionedCodable

let emptyJSONObject = "{}".data(using: .utf8)!


@Suite("NothingEarlier")
struct NothingEarlierTests {
    
    @Suite("Configuration", .tags(.configuration))
    struct ConfigurationTests {
        @Test(
            "has a version of `nil`"
        ) func nothingEarlierVersionIsNil() throws {
            #expect(NothingEarlier.version == nil)
        }
        
        @Test(
            "throws if you try to decode anything into it"
        ) func decodingNothingEarlierThrowsAnError() throws {
            #expect {
                try JSONDecoder().decode(
                    NothingEarlier.self,
                    from: emptyJSONObject
                )
            } throws: { error in
                return isTypeMismatch(error, vs: NothingEarlier.self)
            }
        }
    }

    @Test(
        "works properly as the 'stopper' type where there are no previous versions",
        .tags(.behaviour)
    ) func decodingFromSlightlyEarlierType() throws {
        #expect(throws: VersionedDecodingError.unsupportedVersion(tried: VersionedCodableWithoutOlderVersion.self)) {
            try JSONDecoder().decode(
                versioned: VersionedCodableWithoutOlderVersion.self,
                from: emptyJSONObject
            )
        }
    }
}


struct VersionedCodableWithoutOlderVersion: VersionedCodable {
    static let version: Int? = 1
    
    typealias PreviousVersion = NothingEarlier
    
    var text: String
}

extension VersionedDecodingError: Equatable {
    public static func == (lhs: VersionedDecodingError, rhs: VersionedDecodingError) -> Bool {
        switch (lhs, rhs) {
        case let (.unsupportedVersion(leftVersion), .unsupportedVersion(rightVersion)):
            leftVersion == rightVersion
        case (.fieldNoLongerValid, .fieldNoLongerValid):
            true
        default:
            false
        }
    }
    
    
}
