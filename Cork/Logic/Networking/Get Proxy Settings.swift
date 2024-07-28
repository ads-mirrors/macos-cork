//
//  Get Proxy Settings.swift
//  Cork
//
//  Created by David Bureš on 12.08.2023.
//

import Foundation

enum ProxyRetrievalError: Error
{
    case couldNotGetProxyStatus, couldNotGetProxyHost, couldNotGetProxyPort
}
