//
//  URLRequest+Extensions.swift
//  DashdevsNetworking
//
//  Copyright (c) 2021 dashdevs.com. All rights reserved.
//

import Foundation

public extension URLRequest {
    
    /// Property returns a cURL command representation of this URL request.
    var curlString: String {
        guard let url = url else { return "" }
        
        var baseCommand = "curl '\(url.absoluteString)'"
        if httpMethod == "HEAD" {
            baseCommand += " --head"
        }
        
        var command = [baseCommand]
        if let method = httpMethod, method != "HEAD" {
            command.append("-X \(method)")
        }
        
        if let headers = allHTTPHeaderFields {
            for (key, value) in headers where key != "Cookie" {
                command.append("-H '\(key): \(value)'")
            }
        }
        
        if let data = httpBody,
           let body = String(data: data, encoding: .utf8) {
            command.append("-d '\(body)'")
        }
        
        return command.joined(separator: " ")
    }
}
