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
    
    public func get<A>(_ endpoint: Endpoint, deserialise: Deserializator<A>, handler: @escaping (Response<A>, HTTPURLResponse?) -> ()) -> URLSessionTask {
        let descriptor = URLRequestComponents(url: baseURL.appendingEndpoint(endpoint))
        return urlSession.load(descriptor, handler: { (responseData, response, responseError) in
            let validated = self.validate(data: responseData, response: response, error: responseError)
            
            DispatchQueue.main.async {
                handler(validated.result.map(deserialise.parse), validated.response)
            }
        })
    }
    
    public func post<A, B>(_ endpoint: Endpoint, parameters: A, deserialise: Deserializator<B>, handler: @escaping (Response<B>, HTTPURLResponse?) -> ()) -> URLSessionTask
        where A: Encodable, B: Decodable {
        return sendData(endpoint, method: .post, parameters: parameters, deserialise: deserialise, handler: handler)
    }
    
    
    private func sendData<A, B>(_ endpoint: Endpoint, method: HTTPMethod, parameters: A, deserialise: Deserializator<B>, handler: @escaping (Response<B>, HTTPURLResponse?) -> ()) -> URLSessionTask where A: Encodable, B: Decodable {
        let descriptor = URLRequestComponents(url: baseURL.appendingEndpoint(endpoint), params: parameters, method: method)
        return urlSession.send(descriptor, handler: { (responseData, response, responseError) in
            let validated = self.validate(data: responseData, response: response, error: responseError)
            DispatchQueue.main.async {
                handler(validated.result.map(deserialise.parse), validated.response)
            }
        })
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
