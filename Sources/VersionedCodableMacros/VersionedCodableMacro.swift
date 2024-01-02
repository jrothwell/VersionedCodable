//
//  VersionedCodableMacro.swift
//
//
//  Created by Jonathan Rothwell on 15/06/2023.
//
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
import SwiftDiagnostics

enum VersionedCodableMacroError: CustomStringConvertible, Error {
    
    /// The current version has not been specified.
    /// - Note: In principle this will not happen, because the arguments for the exported macro are strongly
    ///   typed. This, however, allows us to test the compiler plugin.
    case missingCurrentVersion
    
    /// The previous version has not been specified.
    /// - Note: In principle this will not happen, because the arguments for the exported macro are strongly
    ///   typed. This, however, allows us to test the compiler plugin.
    case missingPreviousVersion
    
    public var description: String {
        switch self {
        case .missingCurrentVersion:
            return "You must specify the current version of the type, even if there isn't one."
        case .missingPreviousVersion:
            return "You must specify a previous version of the type, even if there isn't one."
        }
    }
    
}

public struct VersionedCodableMacro {}

extension VersionedCodableMacro: ExtensionMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                 attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
                                 providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
                                 conformingTo protocols: [SwiftSyntax.TypeSyntax],
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        
        guard case .argumentList(let arguments) = node.arguments else {
            context.addDiagnostics(from: VersionedCodableMacroError.missingCurrentVersion, node: node)
            context.addDiagnostics(from: VersionedCodableMacroError.missingPreviousVersion, node: node)
            return []
        }
        
        guard let version = arguments.version else {
            context.addDiagnostics(from: VersionedCodableMacroError.missingCurrentVersion, node: node)
            return []
        }
        
        guard let previousVersion = arguments.previousVersion else {
            context.addDiagnostics(from: VersionedCodableMacroError.missingPreviousVersion, node: node)
            return []
        }

        return [
            DeclSyntax("""
                       extension \(type.trimmed): VersionedCodable {
                           static let version: Int? = \(version)
                           typealias PreviousVersion = \(previousVersion)
                       }
                       """).cast(ExtensionDeclSyntax.self)
        ]
    }
}

private extension LabeledExprListSyntax {
    var version: TokenSyntax? {
        self.filter({
            guard case .identifier(let label) =
                    $0.label?.tokenKind else { return false }
            return label == "v"
        }).first?.expression.firstToken(viewMode: .fixedUp)
    }
    
    var previousVersion: TokenSyntax? {
        self.filter({
            guard case .identifier(let label) = $0.label?.tokenKind else { return false }
            return label == "previously"
        }).first?.expression.firstToken(viewMode: .fixedUp)
    }

}

