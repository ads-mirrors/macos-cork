//
//  Package Types.swift
//  Cork
//
//  Created by David Bureš on 05.02.2023.
//

import AppIntents
import Charts
import Foundation

public enum PackageType: String, CustomStringConvertible, Plottable, AppEntity
{
    case formula
    case cask

    public var description: String
    {
        switch self
        {
        case .formula:
            return String(localized: "package-details.type.formula")
        case .cask:
            return String(localized: "package-details.type.cask")
        }
    }

    public static var typeDisplayRepresentation: TypeDisplayRepresentation = .init(name: "package-details.type")

    public var displayRepresentation: DisplayRepresentation
    {
        switch self
        {
        case .formula:
            DisplayRepresentation(title: "package-details.type.formula")
        case .cask:
            DisplayRepresentation(title: "package-details.type.cask")
        }
    }
}
