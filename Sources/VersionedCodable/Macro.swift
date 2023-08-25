//
//  VersionedCodableMacro.swift
//
//
//  Created by Jonathan Rothwell on 15/06/2023.
//

import Foundation

@attached(extension, conformances: VersionedCodable, names: named(version), named(PreviousVersion))
public macro versionedCodable(v: Int?, previously: any VersionedCodable.Type) = #externalMacro(
    module: "VersionedCodableMacros",
    type: "VersionedCodableMacro")
