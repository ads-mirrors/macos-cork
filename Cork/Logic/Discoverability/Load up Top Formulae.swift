//
//  Load up Top Formulae.swift
//  Cork
//
//  Created by David Bureš on 22.06.2024.
//

import Foundation

extension TopPackagesTracker
{
    /// The internal struct allowing us to parse the top packages
    fileprivate struct TopFormulaeOutput: Codable
    {
        /// What we actually care about
        struct TopFormulaItem: Codable
        {
            /// The name of the formula
            let formula: String

            /// How many times this formula has been installed
            let count: String
        }

        let items: [TopFormulaItem]
    }

    func loadTopFormulae() async throws
    {
        /// Get how many days we have to load
        let numberOfDays: Int = UserDefaults.standard.integer(forKey: "discoverabilityDaySpan")
        
        let decoder: JSONDecoder =
        {
            let decoder: JSONDecoder = .init()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            return decoder
        }()

        do
        {
            let rawData: Data = try await downloadDataFromURL(URL(string: "https://formulae.brew.sh/api/analytics/install-on-request/\(numberOfDays)d.json")!)
            
            do
            {
                let decodedData: TopFormulaeOutput = try decoder.decode(TopFormulaeOutput.self, from: rawData)
                
                var topFormulaeTempTracker: [TopPackage] = .init()
                
                for topFormula in decodedData.items
                {
                    topFormulaeTempTracker.append(.init(
                        packageName: topFormula.formula,
                        packageDownloads: Int(topFormula.count) ?? 0)
                    )
                }
                
                self.topFormulae = topFormulaeTempTracker
            }
            catch let parsingError
            {
                AppConstants.logger.error("Failed while parsing top formulae: \(parsingError)")
            }
        }
        catch let dataLoadingError as DataDownloadingError
        {
            switch dataLoadingError
            {
            case .invalidResponseCode:
                AppConstants.logger.warning("Received invalid response code from Brew")

                throw dataLoadingError

            case .noDataReceived:
                AppConstants.logger.warning("Received no data from Brew")

                throw dataLoadingError

            case .invalidURL:
                print("Invalid URL")

                throw dataLoadingError
            }
        }
    }
}
