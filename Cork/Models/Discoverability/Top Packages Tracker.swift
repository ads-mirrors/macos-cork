//
//  Top Packages Tracker.swift
//  Cork
//
//  Created by David Bureš on 19.08.2023.
//

import Foundation

@MainActor
final class TopPackagesTracker: ObservableObject, Sendable
{
    @Published var topFormulae: [TopPackage] = .init()
    @Published var topCasks: [TopPackage] = .init()
}
