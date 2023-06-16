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
            @Versioned(version: 1)
            struct Poem {
                var author: String
                var body: String
            }
            """,
            expandedSource:
            """
            
            struct Poem {
                var author: String
                var body: String
                static let version: Int? = 1
            }
            """, macros: ["Versioned": Versioned.self])
    }
    
    func testMoreComplexExpansion() throws {
        assertMacroExpansion(
            """
            @Versioned(version: 42)
            struct Poem {
                var author: String
                var body: String
            }
            """,
            expandedSource:
            """
            
            struct Poem {
                var author: String
                var body: String
                static let version: Int? = 42
            }
            """, macros: ["Versioned": Versioned.self])
    }
    
    func testExpansionWithNilVersion() throws {
        assertMacroExpansion(
            """
            @Versioned(version: nil)
            struct Poem {
                var author: String
                var body: String
            }
            """,
            expandedSource:
            """
            
            struct Poem {
                var author: String
                var body: String
                static let version: Int? = nil
            }
            """, macros: ["Versioned": Versioned.self])
    }

}
