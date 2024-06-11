//
//  NothingEarlierConformanceConfidenceTests.swift
//  
//
//  Created by Jonathan Rothwell on 15/04/2023.
//

import XCTest
import Testing
@testable import VersionedCodable

@Suite("NothingEarlier")
struct NothingEarlierConformanceConfidenceTests {
    
    let blankData = "{}".data(using: .utf8)!
    
    @Test(
        "has a version of `nil`",
        .tags(.configuration)
    ) func nothingEarlierVersionIsNil() throws {
        #expect(NothingEarlier.version == nil)
    }
    
    @Test(
        "throws if you try to decode anything into it",
        .tags(.configuration)
    ) func decodingNothingEarlierThrowsAnError() throws {
        
        // TODO: 20/09/2024: The helper function is necessary due to some kind of issue with macro expansion. Remove this once the bug (in the compiler?) is resolved.
        func isTypeMismatchVsNothingEarlier(error: Error) -> Bool {
            switch error {
            case DecodingError.typeMismatch(let type, _):
                return type == NothingEarlier.self
            default:
                return false
            }
        }
        
        #expect {
            try JSONDecoder().decode(
                NothingEarlier.self,
                from: blankData
            )
        } throws: { error in
            return isTypeMismatchVsNothingEarlier(error: error)
        }
    }
    
    @Test(
        "works properly as the 'stopper' type where there are no previous versions",
        .tags(.behaviour)
    ) func decodingFromSlightlyEarlierType() throws {
        #expect(throws: VersionedDecodingError.unsupportedVersion(tried: VersionedCodableWithoutOlderVersion.self)) {
            try JSONDecoder().decode(
                versioned: VersionedCodableWithoutOlderVersion.self,
                from: blankData
            )
        }
    }
}

struct VersionedCodableWithoutOlderVersion: VersionedCodable {
    static let version: Int? = 1
    
    typealias PreviousVersion = NothingEarlier
    
    var text: String
}

extension VersionedDecodingError: @retroactive Equatable {
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
