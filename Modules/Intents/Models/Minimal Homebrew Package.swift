//
//  Minimal Homebrew Package.swift
//  Cork
//
//  Created by David Bureš on 25.05.2024.
//

import AppIntents
import Foundation
import CorkShared

public struct MinimalHomebrewPackage: Identifiable, Hashable, AppEntity
{
    public var id: UUID = .init()

    public var name: String

    public var type: PackageType

    public var installDate: Date?

    public var installedIntentionally: Bool

    static public var typeDisplayRepresentation: TypeDisplayRepresentation = .init(name: "intents.type.minimal-homebrew-package")

    public var displayRepresentation: DisplayRepresentation
    {
        DisplayRepresentation(
            title: "\(name)",
            subtitle: "intents.type.minimal-homebrew-package.representation.subtitle"
        )
    }

    static public var defaultQuery: MinimalHomebrewPackageIntentQuery = .init()
}

public struct MinimalHomebrewPackageIntentQuery: EntityQuery
{
    public init()
    {
        
    }
    
    public func entities(for _: [UUID]) async throws -> [MinimalHomebrewPackage]
    {
        return .init()
    }
}
