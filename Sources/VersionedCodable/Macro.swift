//
//  Macro.swift
//
//
//  Created by Jonathan Rothwell on 15/06/2023.
//

import Foundation


/// Makes the attached type conform to ``VersionedCodable``.
/// - Parameters:
///     - v:  The current version of this type. This is what is encoded into the `version` key on this type
/// when it is encoded.
///     - previously: The next oldest version of this type, or ``NothingEarlier`` if this *is* the oldest version.
/// - Note: If your type has a previous version, you will need to implement an initializer for it. This is where you
///   do the mapping between the old and the new version of the type.
/// - SeeAlso: ``VersionedCodable``
@attached(extension, conformances: VersionedCodable, names: named(version), named(PreviousVersion))
public macro versionedCodable(v: Int?, previously: any VersionedCodable.Type) = #externalMacro(
    module: "VersionedCodableMacros",
    type: "VersionedCodableMacro")
