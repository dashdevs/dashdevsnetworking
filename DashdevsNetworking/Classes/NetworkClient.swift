//
//  NetworkClient.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

/// This protocol provides describes basic wrapper functionality
public protocol SessionNetworking {
    var baseURL: URL { get }
    var urlSession: URLSession { get }
}

/// This class wraps URLSession functionality and provides neat functionality
public class NetworkClient: SessionNetworking {
    public let baseURL: URL
    public let urlSession: URLSession
    
    /// Constructor method
    ///
    /// - Parameters:
    ///   - base: base URL to use
    ///   - sessionConfiguration: configuration of URL session to use
    public init(_ base: URL, sessionConfiguration: URLSessionConfiguration = .default) {
        self.baseURL = base
        self.urlSession = URLSession(configuration: sessionConfiguration)
    }
    
    /// Method for building resource URL
    ///
    /// - Parameter endpoint: part of URL to append
    /// - Returns: complete URL of resource
    public func buildURL(_ endpoint: Endpoint) -> URL {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        components?.path = endpoint.path
        if !endpoint.queryItems.isEmpty {
            components?.queryItems = endpoint.queryItems
        }
        
        guard let url = components?.url else {
            preconditionFailure("Incorrect url!")
        }
        return url
    }
        
    /// This property describes range of acceptable HTTP status codes
    public var acceptableHTTPCodes: [Int] {
        let codes = [Int](200...300)
        return codes
    }
    
    /// This method is used for validating returned from server
    ///
    /// - Parameters:
    ///   - data: The data returned by the server
    ///   - response: An object that provides response metadata, such as HTTP headers and status code
    ///   - error: An error object that indicates why the request failed, or nil if the request was successful
    /// - Returns: Tuple with response data and url response
    public func validate(data: Data?, response: URLResponse?, error: Error?) -> (result: Response<Data>, response: HTTPURLResponse?) {
        guard let httpResponse = response as? HTTPURLResponse else {
            return (Response.failure(NetworkError.emptyResponse), nil)
        }
        
        if let error = error {
            return (Response.failure(error), httpResponse)
        }
        
        guard httpResponse.validateStatusCode(acceptableHTTPCodes) else {
            return (Response.failure(NetworkError.HTTP(httpResponse.statusCode)), httpResponse)
        }
        
        guard let data = data else {
            return (Response.failure(NetworkError.emptyResponse), httpResponse)
        }
        return (Response.success(data), httpResponse)
    }
    
    deinit {
        urlSession.invalidateAndCancel()
    }
}
