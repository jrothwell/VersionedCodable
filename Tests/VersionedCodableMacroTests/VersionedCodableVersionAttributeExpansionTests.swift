//
//  VersionedCodableMacroExpansionTests.swift
//  
//
//  Created by Jonathan Rothwell on 15/06/2023.
//

import XCTest
import SwiftSyntaxMacrosTestSupport
@testable import VersionedCodableMacros

final class VersionedCodableVersionAttributeExpansionTests: XCTestCase {

    func testSimpleExpansion() throws {
        assertMacroExpansion(
            """
            @versionedCodable(v: 1)
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
            }
            
            extension Poem: VersionedCodable {
                static let version: Int? = 1
            }
            """, macros: ["versionedCodable": VersionedCodableMacro.self])
    }
    
    func testMoreComplexExpansion() throws {
        assertMacroExpansion(
            """
            @versionedCodable(v: 42)
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
            }
            
            extension Poem: VersionedCodable {
                static let version: Int? = 42
            }
            """, macros: ["versionedCodable": VersionedCodableMacro.self])
    }
    
    func testExpansionWithNilVersion() throws {
        assertMacroExpansion(
            """
            @versionedCodable(v: nil)
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
            }
            
            extension Poem: VersionedCodable {
                static let version: Int? = nil
            }
            """, macros: ["versionedCodable": VersionedCodableMacro.self])
    }

}
