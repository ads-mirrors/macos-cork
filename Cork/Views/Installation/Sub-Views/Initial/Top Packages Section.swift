//
//  Top Packages Section.swift
//  Cork
//
//  Created by David Bureš on 17.10.2023.
//

import SwiftUI

struct TopPackagesSection: View
{
    @AppStorage("sortTopPackagesBy") var sortTopPackagesBy: TopPackageSorting = .mostDownloads
    
    @EnvironmentObject var brewData: BrewDataStorage
    @EnvironmentObject var topPackageTracker: TopPackagesTracker

    let isCaskTracker: Bool
    
    var displayedTopPackages: [TopPackage]
    {
        if !isCaskTracker
        {
            switch sortTopPackagesBy {
                case .mostDownloads:
                    return topPackageTracker.topFormulae
                case .fewestDownloads:
                    return topPackageTracker.bottomTopFormulae
                case .random:
                    return (topPackageTracker.topFormulae + topPackageTracker.bottomTopFormulae).shuffled()
            }
        }
        else
        {
            switch sortTopPackagesBy {
                case .mostDownloads:
                    return topPackageTracker.topCasks
                case .fewestDownloads:
                    return topPackageTracker.bottomTopCasks
                case .random:
                    return (topPackageTracker.topCasks + topPackageTracker.bottomTopCasks).shuffled()
            }
        }
    }

    @State private var isCollapsed: Bool = false

    var body: some View
    {
        Section
        {
            if !isCollapsed
            {
                ForEach(displayedTopPackages.filter
                {
                    if !isCaskTracker
                    {
                        !brewData.installedFormulae.map(\.name).contains($0.packageName)
                    }
                    else
                    {
                        !brewData.installedCasks.map(\.name).contains($0.packageName)
                    }
                })
                { topPackage in
                    TopPackageListItem(topPackage: topPackage)
                }
            }
        } header: {
            CollapsibleSectionHeader(headerText: isCaskTracker ? "add-package.top-casks" : "add-package.top-formulae", isCollapsed: $isCollapsed)
        }
    }
}
