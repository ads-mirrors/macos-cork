//
//  Top Packages Tracker.swift
//  Cork
//
//  Created by David Bureš on 19.08.2023.
//

import Foundation

class TopPackagesTracker: ObservableObject
{
    @Published var topFormulae: [TopPackage] = .init()
    @Published var topCasks: [TopPackage] = .init()
    
    /// These hold the packages for the "fewest downloads" sorting type, e.g. packages that are popular, but don't have the most downloads
    @Published var bottomTopFormulae: [TopPackage] = .init()
    @Published var bottomTopCasks: [TopPackage] = .init()
}
