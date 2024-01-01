//
//  VersionedCodableMacro.swift
//
//
//  Created by Jonathan Rothwell on 15/06/2023.
//
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public struct Versioned {}

extension Versioned: MemberMacro {
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

extension Versioned: ExtensionMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        
        let declaredExtension: DeclSyntax =
        """
            extension \(type.trimmed): VersionedCodable {}
        """
        guard let versionedCodableExtension = declaredExtension.as(ExtensionDeclSyntax.self) else {
            return []
        }
        return [versionedCodableExtension]
    }
    
    public static func expansion<Declaration, Context>(
        of node: SwiftSyntax.AttributeSyntax,
        providingConformancesOf declaration: Declaration,
        in context: Context) throws ->
    [(SwiftSyntax.TypeSyntax, SwiftSyntax.GenericWhereClauseSyntax?)] where Declaration : SwiftSyntax.DeclGroupSyntax,
    Context : SwiftSyntaxMacros.MacroExpansionContext {
        return [("VersionedCodable", nil)]
    }
    
    
}

private extension SwiftSyntax.AttributeSyntax {
    var version: TokenSyntax? {
        guard case .argumentList(let arguments) = self.arguments else {
            return nil
        }
        
        
        guard let expression = arguments.filter({
            guard case .identifier(let label) = $0.label?.tokenKind else { return false }
            return label == "version"
        }).first?.expression else { return nil }
        
//        if let integerLiteral = expression.as(IntegerLiteralExprSyntax.self) {
//            return integerLiteral.digits
//        } else {
            return expression.firstToken(viewMode: .fixedUp)!
//        }
    }
}

