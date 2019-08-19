//
//  NetworkClient.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

/// This protocol provides describes basic networking functionality
public protocol SessionNetworking {
    var baseURL: URL { get }
    var urlSession: URLSession { get }
    var authorization: Authorization? { get }
}

/// This class uses URLSession for organising networking
open class NetworkClient: SessionNetworking {
    public let baseURL: URL
    public let urlSession: URLSession
    public var authorization: Authorization?
    
    /// Constructor method
    ///
    /// - Parameters:
    ///   - base: base URL to use
    ///   - sessionConfiguration: configuration of URL session to use
    ///   - authorization: authorization strategy to use
    public init(_ base: URL, sessionConfiguration: URLSessionConfiguration = .default, authorization: Authorization? = nil) {
        self.baseURL = base
        self.urlSession = URLSession(configuration: sessionConfiguration)
        self.authorization = authorization
    }
    
    /// Method for retrieving data from server with specified endpoint
    ///
    /// - Parameters:
    ///   - endpoint: Parameter describing resource location
    ///   - deserialise: Parameter describing how response will be parsed
    ///   - handler: The completion handler to call when the load request and response data parsing is complete
    /// - Returns: The new session data task
    @discardableResult
    public func get<A>(_ endpoint: Endpoint, deserialise: Deserializator<A>, headers: [HTTPHeader] = [], handler: @escaping (Response<A>, HTTPURLResponse?) -> ()) -> URLSessionTask {
        let descriptor = makeDescriptor(endpoint: endpoint, headers: headers + deserialise.headers)
        let task = urlSession.load(descriptor, handler: { (responseData, response, responseError) in
            let validated = self.validate(data: responseData, response: response, error: responseError)
                        
            DispatchQueue.main.async {
                handler(validated.result.map(deserialise.parse), validated.response)
            }
        })
        
        task.resume()
        return task
    }

    /// This method should be used for loading data from server
    ///
    /// - Parameters:
    ///   - endpoint: Parameter describing resource location
    ///   - parameters: These are options that are included in request body
    ///   - deserialise: Parameter describing how response will be parsed
    ///   - handler: The completion handler to call when the load request and response data parsing is complete
    /// - Returns: The new session data task
    @discardableResult
    public func post<A, B>(_ endpoint: Endpoint, parameters: A, headers: [HTTPHeader] = [], deserialise: Deserializator<B>, handler: @escaping (Response<B>, HTTPURLResponse?) -> ()) -> URLSessionTask
        where A: Encodable {
        let task = sendData(endpoint, method: .post, parameters: parameters, deserialise: deserialise, handler: handler)
        task.resume()
        return task
    }
    
    private func sendData<A, B>(_ endpoint: Endpoint, method: HTTPMethod, parameters: A, headers: [HTTPHeader] = [], deserialise: Deserializator<B>, handler: @escaping (Response<B>, HTTPURLResponse?) -> ()) -> URLSessionTask where A: Encodable {
        let descriptor = makeDescriptor(endpoint, params: parameters, headers: headers + deserialise.headers, method: method)
        return urlSession.send(descriptor, handler: { (responseData, response, responseError) in
            let validated = self.validate(data: responseData, response: response, error: responseError)
            DispatchQueue.main.async {
                handler(validated.result.map(deserialise.parse), validated.response)
            }
        })
    }
    
    func load<Descriptor: RequestDescriptor>(_ descriptor: Descriptor, handler: @escaping (Response<Descriptor.Resource>, HTTPURLResponse?) -> ()) -> URLSessionTask where Descriptor.Resource: Decodable {
        return urlSession.load(baseURL, descriptor: descriptor, handler: { (data, response, error) in
            let validated = self.validate(data: data, response: response, error: error)
            DispatchQueue.main.async {
                handler(validated.result.map(descriptor.response.parse), validated.response)
            }
        })
    }
    
    func send<Descriptor: RequestDescriptor>(_ descriptor: Descriptor, handler: @escaping (Response<Descriptor.Resource>, HTTPURLResponse?) -> ()) -> URLSessionTask where Descriptor.Resource: Decodable, Descriptor.Parameters: Encodable {
        return urlSession.send(baseURL, descriptor: descriptor, handler: { (data, response, error) in
            let validated = self.validate(data: data, response: response, error: error)
            DispatchQueue.main.async {
                handler(validated.result.map(descriptor.response.parse), validated.response)
            }
        })
    }
    
    open func makeDescriptor<A>(_ endpoint: Endpoint, params: A, headers: [HTTPHeader], method: HTTPMethod) -> URLRequestComponents where A: Encodable {
        let url = constructURL(endpoint)
        var components = URLRequestComponents(url: url, params: params, method: method, headers: headers)
        authorization?.authorize(&components)
        return components
    }
    
    open func makeDescriptor(endpoint: Endpoint, headers: [HTTPHeader]) -> URLRequestComponents {
        let url = constructURL(endpoint)
        var components = URLRequestComponents(url: url, method: .get, headers: headers)
        authorization?.authorize(&components)
        return components
    }
    
    open func constructURL(_ endpoint: Endpoint) -> URL {
        return baseURL.appending(endpoint)
    }
    
    /// This property describes range of acceptable HTTP status codes
    open var acceptableHTTPCodes: [Int] {
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
    open func validate(data: Data?, response: URLResponse?, error: Error?) -> (result: Response<Data>, response: HTTPURLResponse?) {
        guard let httpResponse = response as? HTTPURLResponse else {
            return (Response.failure(NetworkError.emptyResponse), nil)
        }
        
        if let error = error {
            return (Response.failure(error), httpResponse)
        }
        
        let statusCode = httpResponse.statusCode
        
        guard acceptableHTTPCodes.contains(statusCode) else {
            return (Response.failure(NetworkError.HTTP(statusCode)), httpResponse)
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
