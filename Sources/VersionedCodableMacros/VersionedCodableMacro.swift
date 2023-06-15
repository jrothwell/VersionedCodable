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
                                       return [
                                        "static let version = 1"
                                       ]
    }
    
    
}

