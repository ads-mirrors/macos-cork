//
//  Load up Top Casks.swift
//  Cork
//
//  Created by David Bureš on 22.06.2024.
//

import Foundation

extension TopPackagesTracker
{
    /// The internal struct allowing us to parse the top casks
    fileprivate struct TopCasksOutput: Codable
    {
        /// What we actually care about
        struct TopCaskItem: Codable
        {
            /// The name of the cask
            let cask: String
            
            /// How many times this cask has been installed
            let count: String
        }
        
        let items: [TopCaskItem]
    }
    
    func loadTopCasks() async throws
    {
        /// Get how many days we have to load
        let numberOfDays: Int = UserDefaults.standard.integer(forKey: "discoverabilityDaySpan")
        
        /// The magic number here is the result of 1000/30, a base limit for 30 days: If the user selects the number of days to be 30, only show packages with more than 1000 downloads
        let packageDownloadsCutoff: Int = 33 * numberOfDays
        
        AppConstants.logger.debug("Cutoff for casks downloads: \(packageDownloadsCutoff, privacy: .public)")
        
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
                let decodedData: TopCasksOutput = try decoder.decode(TopCasksOutput.self, from: rawData)
                
                var topCasksTempTracker: [TopPackage] = .init()
                
                for topCask in decodedData.items
                {
                    if Int(topCask.count)! > packageDownloadsCutoff
                    {
                        topCasksTempTracker.append(.init(
                            packageName: topCask.cask,
                            packageDownloads: Int(topCask.count) ?? 0)
                        )
                    }
                    else
                    {
                        /// Discard any items that don't meet the download cutoff requirement
                        break
                    }
                }
                
                self.topFormulae = topCasksTempTracker
            }
            catch let parsingError
            {
                AppConstants.logger.error("Failed while parsing top casks: \(parsingError)")
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
