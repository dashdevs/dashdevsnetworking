//
//  NetworkDebugLog.swift
//  DashdevsNetworking
//
//  Copyright (c) 2021 dashdevs.com. All rights reserved.
//

import Foundation

/// This class is used to display the debug log of the network layer
class NetworkDebugLog {
    /// This method is used to display debug log for request the server
    ///
    /// - Parameters:
    ///   - request: An object that provides request metadata
    ///   - displayNetworkDebugLog: An object that provides a location for displaying logs
    static func log(with request: URLRequest, displayNetworkDebugLog: DisplayNetworkDebugLog?) {
        switch displayNetworkDebugLog {
        case .console:
            debugPrint()
            debugPrint("==>>==========================================")
            debugPrint("REQUEST")
            debugPrint("\(request.curlString)")
            debugPrint("==>>==========================================")
            debugPrint()
        case .none:
            break
        }
    }
    
    /// This method is used to display debug log for response the server
    ///
    /// - Parameters:
    ///   - data: The data returned by the server
    ///   - response: An object that provides response metadata, such as HTTP headers and status code
    ///   - error: An error object that indicates why the request failed, or nil if the request was successful. Apple doc states that error will be returned in the NSURLErrorDomain
    ///   - displayNetworkDebugLog: An object that provides a location for displaying logs
    static func log(with data: Data?, response: URLResponse?, error: Error?, displayNetworkDebugLog: DisplayNetworkDebugLog?) {
        switch displayNetworkDebugLog {
        case .console:
            debugPrint()
            debugPrint("==>>==========================================")
            debugPrint("RESPONSE")
            
            if let response = response as? HTTPURLResponse {
                debugPrint(response.url?.absoluteString ?? "")
                debugPrint("Status Code: \(response.statusCode)")
                debugPrint()
                
                for (key,value) in response.allHeaderFields {
                    debugPrint("Header: \(key): \(value)")
                }
                debugPrint()
            }
            
            if let data = data {
                let bodyString = String(data: data, encoding: .utf8) ?? "Can't render body; not utf8 encoded"
                debugPrint("Body: \(bodyString)")
            }
            
            if let error = error {
                debugPrint("Error: \(error)")
            }
            
            debugPrint("==>>==========================================")
        case .none:
            break
        }
    }
}
