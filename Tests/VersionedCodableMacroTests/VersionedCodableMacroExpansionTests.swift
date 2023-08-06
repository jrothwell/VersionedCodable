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
            @versionedCodable(v: 1)
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
            """, macros: ["versionedCodable": VersionedCodableMacro.self])
    }
    
    func testMoreComplexExpansion() throws {
        assertMacroExpansion(
            """
            @versionedCodable(v: 42)
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
            """, macros: ["versionedCodable": VersionedCodableMacro.self])
    }
    
    func testExpansionWithNilVersion() throws {
        assertMacroExpansion(
            """
            @versionedCodable(v: nil)
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
            """, macros: ["versionedCodable": VersionedCodableMacro.self])
    }

}
