//
//  NetworkError.swift
//  URLSessionWrapper
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

/// This general enum describes domain of network errors
///
/// - emptyResponse: Server returned empty response
public enum NetworkError: LocalizedError {
    case emptyResponse
    
    /// Describes domain of errors that occur while deserialising data
    ///
    /// - convertingFailed: Error occured while trying to parse result
    public enum Deserialisation: LocalizedError {
        case convertingFailed
    }
    
    /// Describes domain of HTTP error status codes
    ///
    /// - client: Malformed by client request
    /// - unautorized: The request requires user authentication
    /// - notFound: Server has not found resource matching URL
    /// - forbidden: The server understood the request, but is refusing to fulfill it.
    /// - server: The server encountered an unexpected condition which prevented it from fulfilling the request
    public enum HTTP: LocalizedError {
        case client
        case unautorized
        case notFound
        case forbidden
        case server
        
        public init(_ statusCode: Int) {
            switch statusCode {
            case 400:
                self = .client
            case 401:
                self = .unautorized
            case 404:
                self = .notFound
            case 403:
                self = .forbidden
            case 500:
                self = .server
            default:
                self = .server
            }
        }
    }
}
