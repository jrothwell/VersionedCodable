//
//  VersionedCodableMacro.swift
//
//
//  Created by Jonathan Rothwell on 15/06/2023.
//

import Foundation

@attached(member, names: named(version))
@attached(extension, conformances: VersionedCodable)
public macro versionedCodable(v: Int?) = #externalMacro(
    module: "VersionedCodableMacros",
    type: "VersionedCodableMacro")
