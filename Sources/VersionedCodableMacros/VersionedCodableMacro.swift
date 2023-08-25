//
//  VersionedCodableMacro.swift
//
//
//  Created by Jonathan Rothwell on 15/06/2023.
//
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public struct VersionedCodableMacro {}

extension VersionedCodableMacro: ExtensionMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                 attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
                                 providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
                                 conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        guard let version = node.version,
              let previousVersion = node.previousVersion else { return [] }

        return [
            DeclSyntax("""
                       extension \(type.trimmed): VersionedCodable {
                           static let version: Int? = \(raw: version.text)
                           typealias PreviousVersion = \(raw: previousVersion.text)
                       }
                       """).cast(ExtensionDeclSyntax.self)
        ]
    }
    
    
}

private extension SwiftSyntax.AttributeSyntax {
    var version: TokenSyntax? {
        guard case .argumentList(let arguments) = self.arguments else {
            return nil
        }
        
        guard let expression = arguments.filter({
            guard case .identifier(let label) = $0.label?.tokenKind else { return false }
            return label == "v"
        }).first?.expression else { return nil }
        
        return expression.firstToken(viewMode: .fixedUp)!
    }
    
    var previousVersion: TokenSyntax? {
        guard case .argumentList(let arguments) = self.arguments else {
            return nil
        }
        
        guard let expression = arguments.filter({
            guard case .identifier(let label) = $0.label?.tokenKind else { return false }
            return label == "previously"
        }).first?.expression else { return nil }
        
        return expression.firstToken(viewMode: .fixedUp)!
    }
}

