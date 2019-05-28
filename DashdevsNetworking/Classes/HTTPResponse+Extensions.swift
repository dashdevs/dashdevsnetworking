//
//  HTTPResponse+Extensions.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

public extension HTTPURLResponse {
    
    /// Method for validating HTTP URL response status code
    ///
    /// - Parameter acceptable: Array of accepted status codes
    /// - Returns: Value indicating is response valid or not
    func validateStatusCode(_ acceptable: [Int]) -> Bool {
        return acceptable.contains(statusCode)
    }
    
    /// Method for validating HTTP URL response MIME type
    ///
    /// - Parameter acceptable: Array of acceptable MIME types
    /// - Returns: Value indicating is response valid or not
    func validateMIME(_ acceptable: [String]) -> Bool {
        guard let mimetype = mimeType else { return false }
        return acceptable.contains(mimetype)
    }
}
