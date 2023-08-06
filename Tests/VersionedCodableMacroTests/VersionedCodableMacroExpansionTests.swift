//
//  VersionedCodableMacroExpansionTests.swift
//  
//
//  Created by Jonathan Rothwell on 15/06/2023.
//

import XCTest
import SwiftSyntaxMacrosTestSupport
@testable import VersionedCodableMacros

final class VersionedCodableMacroExpansionTests: XCTestCase {

    func testSimpleExpansion() throws {
        assertMacroExpansion(
            """
            @versioned(version: 1)
            struct Poem: VersionedCodable {
                var author: String
                var body: String
            }
            """,
            expandedSource:
            """
            
            struct Poem: VersionedCodable {
                var author: String
                var body: String
                static let version: Int? = 1
            }
            """, macros: ["versioned": Versioned.self])
    }
    
    func testMoreComplexExpansion() throws {
        assertMacroExpansion(
            """
            @versioned(version: 42)
            struct Poem: VersionedCodable {
                var author: String
                var body: String
            }
            """,
            expandedSource:
            """
            
            struct Poem: VersionedCodable {
                var author: String
                var body: String
                static let version: Int? = 42
            }
            """, macros: ["versioned": Versioned.self])
    }
    
    func testExpansionWithNilVersion() throws {
        assertMacroExpansion(
            """
            @versioned(version: nil)
            struct Poem: VersionedCodable {
                var author: String
                var body: String
            }
            """,
            expandedSource:
            """
            
            struct Poem: VersionedCodable {
                var author: String
                var body: String
                static let version: Int? = nil
            }
            """, macros: ["versioned": Versioned.self])
    }

}
