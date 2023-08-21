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

extension VersionedCodableMacro: MemberMacro {
    public static func expansion<Declaration, Context>(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context) throws ->
    [SwiftSyntax.DeclSyntax] where Declaration : SwiftSyntax.DeclGroupSyntax,
                                   Context : SwiftSyntaxMacros.MacroExpansionContext {
                                       guard let version = node.version else { return [] }
                                       return [
                                        "static let version: Int? = \(raw: version.text)"
                                       ]
    }
}

extension VersionedCodableMacro: ExtensionMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        [
            DeclSyntax("extension \(type.trimmed): VersionedCodable {}").cast(ExtensionDeclSyntax.self)
        ]
    }
    
    
}

private extension SwiftSyntax.AttributeSyntax {
    var version: TokenSyntax? {
        guard case .argumentList(let arguments) = self.argument else {
            return nil
        }
        
        
        guard let expression = arguments.filter({
            guard case .identifier(let label) = $0.label?.tokenKind else { return false }
            return label == "v"
        }).first?.expression else { return nil }
        
            return expression.firstToken(viewMode: .fixedUp)!
    }
}

