//
//  VersionedCodableMacros.swift
//
//
//  Created by Jonathan Rothwell on 15/06/2023.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct VersionedCodablePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        Versioned.self
    ]
}
