//
//  Versioned.swift
//
//
//  Created by Jonathan Rothwell on 15/06/2023.
//

import Foundation

@attached(member, names: named(version))
@attached(extension, conformances: VersionedCodable)
public macro versioned(version: Int?) = #externalMacro(
    module: "VersionedCodableMacros",
    type: "Versioned")
