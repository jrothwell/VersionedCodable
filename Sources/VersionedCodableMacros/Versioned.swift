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

extension Versioned: ConformanceMacro {
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
        guard case .argumentList(let arguments) = self.argument else {
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

