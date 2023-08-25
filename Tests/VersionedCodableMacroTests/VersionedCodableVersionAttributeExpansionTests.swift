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
            @versionedCodable(v: 1, previously: PoemOld.self)
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
                typealias PreviousVersion = PoemOld
            }
            """, macros: ["versionedCodable": VersionedCodableMacro.self])
    }
    
    func testMoreComplexExpansion() throws {
        assertMacroExpansion(
            """
            @versionedCodable(v: 42, previously: PoemPrevious.self)
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
                typealias PreviousVersion = PoemPrevious
            }
            """, macros: ["versionedCodable": VersionedCodableMacro.self])
    }
    
    func testExpansionWithNilVersion() throws {
        assertMacroExpansion(
            """
            @versionedCodable(v: nil, previously: PoemOld.self)
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
                typealias PreviousVersion = PoemOld
            }
            """, macros: ["versionedCodable": VersionedCodableMacro.self])
    }
    
    func testExpansionWithNothingEarlier() throws {
        assertMacroExpansion(
            """
            @versionedCodable(v: nil, previously: NothingEarlier.self)
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
                typealias PreviousVersion = NothingEarlier
            }
            """, macros: ["versionedCodable": VersionedCodableMacro.self])
    }

}
