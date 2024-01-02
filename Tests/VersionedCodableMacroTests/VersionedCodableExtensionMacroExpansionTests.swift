//
//  VersionedCodableExtensionMacroExpansionTests.swift
//  
//
//  Created by Jonathan Rothwell on 15/06/2023.
//

import XCTest
import SwiftSyntaxMacrosTestSupport
@testable import VersionedCodableMacros

final class VersionedCodableExtensionMacroExpansionTests: XCTestCase {

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
    
    func testExpansionWhereMissingPreviousType() throws {
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
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "You must specify a previous version of the type, even if there isn't one.",
                    line: 1,
                    column: 1),
            ],
            macros: ["versionedCodable": VersionedCodableMacro.self])
    }
    
    func testExpansionWhereMissingVersion() throws {
        assertMacroExpansion(
            """
            @versionedCodable(previously: OldPoem.self)
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
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "You must specify the current version of the type, even if there isn't one.",
                    line: 1,
                    column: 1),
            ],
            macros: ["versionedCodable": VersionedCodableMacro.self])
    }

    func testExpansionWhereMissingBothArguments() throws {
        assertMacroExpansion(
            """
            @versionedCodable
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
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "You must specify the current version of the type, even if there isn't one.",
                    line: 1,
                    column: 1),
                DiagnosticSpec(
                    message: "You must specify a previous version of the type, even if there isn't one.",
                    line: 1,
                    column: 1)
            ],
            macros: ["versionedCodable": VersionedCodableMacro.self])
    }
}
