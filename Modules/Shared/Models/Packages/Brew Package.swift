//
//  Brew Package.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import AppKit
import DavidFoundation
import Foundation

/// A representation of a Homebrew package
public struct BrewPackage: Identifiable, Equatable, Hashable
{
    public var id: UUID = .init()
    public let name: String

    public lazy var sanitizedName: String? = {
        var packageNameWithoutTap: String
        { /// First, remove the tap name from the package name if it has it
            if self.name.contains("/")
            { /// Check if the package name contains slashes (this would mean it includes the tap name)
                if let sanitizedName = try? self.name.regexMatch("[^\\/]*$")
                {
                    return sanitizedName
                }
                else
                {
                    return self.name
                }
            }
            else
            {
                return self.name
            }
        }

        if packageNameWithoutTap.contains("@")
        { /// Only do the matching if the name contains @
            if let sanitizedName = try? packageNameWithoutTap.regexMatch(".+?(?=@)")
            { /// Try to REGEX-match the name out of the raw name
                return sanitizedName
            }
            else
            { /// If the REGEX matching fails, just show the entire name
                return packageNameWithoutTap
            }
        }
        else
        { /// If the name doesn't contain the @, don't do anything
            return packageNameWithoutTap
        }
    }()

    public let type: PackageType
    public var isTagged: Bool = false

    public let installedOn: Date?
    public let versions: [String]

    public var installedIntentionally: Bool = true

    public let sizeInBytes: Int64?

    public var isBeingModified: Bool = false

    public func getFormattedVersions() -> String
    {
        return versions.formatted(.list(type: .and))
    }

    public mutating func changeTaggedStatus()
    {
        isTagged.toggle()
    }

    public mutating func changeBeingModifiedStatus()
    {
        isBeingModified.toggle()
    }

    public mutating func purgeSanitizedName()
    {
        sanitizedName = nil
    }

    /// Open the location of this package in Finder
    public func revealInFinder() throws
    {
        enum FinderRevealError: LocalizedError
        {
            case couldNotFindPackageInParent

            var errorDescription: String?
            {
                return String(localized: "error.finder-reveal.could-not-find-package-in-parent")
            }
        }

        var packageURL: URL?
        var packageLocationParent: URL
        {
            if type == .formula
            {
                return AppConstants.brewCellarPath
            }
            else
            {
                return AppConstants.brewCaskPath
            }
        }

        let contentsOfParentFolder: [URL] = try! FileManager.default.contentsOfDirectory(at: packageLocationParent, includingPropertiesForKeys: [.isDirectoryKey])

        packageURL = contentsOfParentFolder.filter 
        {
            $0.lastPathComponent.contains(name)
        }.first

        guard let packageURL
        else
        {
            throw FinderRevealError.couldNotFindPackageInParent
        }

        packageURL.revealInFinder(.openParentDirectoryAndHighlightTarget)

        // NSWorkspace.shared.selectFile(packageURL.path, inFileViewerRootedAtPath: packageURL.deletingLastPathComponent().path)
    }
}

public extension FormatStyle where Self == Date.FormatStyle
{
    static var packageInstallationStyle: Self
    {
        dateTime.day().month(.wide).year().weekday(.wide).hour().minute()
    }
}
