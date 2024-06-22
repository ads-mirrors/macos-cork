//
//  Load up Top Formulae.swift
//  Cork
//
//  Created by David Bureš on 22.06.2024.
//

import Foundation

extension TopPackagesTracker
{
    /// The internal struct allowing us to parse the top formulae
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
        
        /// The magic number here is the result of 1000/30, a base limit for 30 days: If the user selects the number of days to be 30, only show packages with more than 1000 downloads
        let packageDownloadsCutoff: Int = 33 * numberOfDays
        
        AppConstants.logger.debug("Cutoff for formulae downloads: \(packageDownloadsCutoff, privacy: .public)")
        
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
                    if Int(topFormula.count)! > packageDownloadsCutoff
                    {
                        topFormulaeTempTracker.append(.init(
                            packageName: topFormula.formula,
                            packageDownloads: Int(topFormula.count) ?? 0)
                        )
                    }
                    else
                    {
                        /// Discard any items that don't meet the download cutoff requirement
                        break
                    }
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
