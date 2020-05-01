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
    var retrier: RequestRetrier? { get }
}

/// This class uses URLSession for organising networking
open class NetworkClient: SessionNetworking {
    public let baseURL: URL
    public let urlSession: URLSession
    public var authorization: Authorization?
    public var retrier: RequestRetrier?
    
    /// Constructor method
    ///
    /// - Parameters:
    ///   - base: base URL to use
    ///   - sessionConfiguration: configuration of URL session to use
    ///   - authorization: authorization strategy to use
    ///   - retrier: retry strategy to use
    public init(_ base: URL, sessionConfiguration: URLSessionConfiguration = .default, authorization: Authorization? = nil, retrier: RequestRetrier? = nil) {
        self.baseURL = base
        self.urlSession = URLSession(configuration: sessionConfiguration)
        self.authorization = authorization
        self.retrier = retrier
    }
    
    /// Method which should be used to load information from remote location
    ///
    /// - Parameters:
    ///   - descriptor: object that describes outgoing request to remote location
    ///   - retryCount: number of request retries
    ///   - handler: block of code to call after url request completes
    ///   - taskHandler: block of code to return current task, like downloading a specific resource, performed in a URL session
    public func load<Descriptor: RequestDescriptor>(_ descriptor: Descriptor, retryCount: UInt = 1, handler: @escaping (Response<Descriptor.Resource>, HTTPURLResponse?) -> (), taskHandler: ((URLSessionTask) -> Void)? = nil) {
        let request = makeRequest(from: descriptor)

        let task = urlSession.dataTask(with: request) { (data, response, error) in
            let validated = self.validate(data: data, response: response, error: error, errorHandler: descriptor.detailedErrorHandler)
            guard retryCount != 0 else {
                DispatchQueue.main.async { handler(validated.result.map(descriptor.response.parse), validated.response) }
                return
            }
            self.retryIfNeeded(request, result: validated.result, retry: {
                self.load(descriptor, retryCount: retryCount - 1, handler: handler, taskHandler: taskHandler)
            }, completion: {
                DispatchQueue.main.async { handler(validated.result.map(descriptor.response.parse), validated.response) }
            })
        }
        task.resume()
        taskHandler?(task)
    }
    
    /// Method which should be used to send information to remote location
    ///
    /// - Parameters:
    ///   - descriptor: object that describes outgoing request to remote location
    ///   - retryCount: number of request retries
    ///   - handler: block of code to call after url request completes
    ///   - taskHandler: block of code to return current task, like downloading a specific resource, performed in a URL session
    public func send<Descriptor: RequestDescriptor>(_ descriptor: Descriptor, retryCount: UInt = 1, handler: @escaping (Response<Descriptor.Resource>, HTTPURLResponse?) -> (), taskHandler: ((URLSessionTask) -> Void)? = nil) {
        
        let request = makeRequest(from: descriptor)
        
        // If http body will be nil - upload task will be cancelled
        let task = urlSession.uploadTask(with: request, from: request.httpBody ?? Data()) { (data, response, error) in
            let validated = self.validate(data: data, response: response, error: error, errorHandler: descriptor.detailedErrorHandler)
            guard retryCount != 0 else {
                DispatchQueue.main.async { handler(validated.result.map(descriptor.response.parse), validated.response) }
                return
            }
            self.retryIfNeeded(request, result: validated.result, retry: {
                self.send(descriptor, retryCount: retryCount - 1, handler: handler, taskHandler: taskHandler)
            }, completion: {
                DispatchQueue.main.async { handler(validated.result.map(descriptor.response.parse), validated.response) }
            })
        }
        task.resume()
        taskHandler?(task)
    }
    
    /// Method which constructs request to remote location using descriptor object
    ///
    /// - Parameter descriptor: object that describes outgoing request to remote location
    /// - Returns: request to remote location object
    open func makeRequest<Descriptor: RequestDescriptor>(from descriptor: Descriptor) -> URLRequest {
        let url = constructURL(descriptor.path, versioned: descriptor.versionPath)
        var request = URLRequest(url: url)
        request.httpMethod = descriptor.method.rawValue
        
        descriptor.encoding.map({ $0.headers.forEach({ request.setValue($0.value, forHTTPHeaderField: $0.field) }) })
        descriptor.response.headers.forEach({ request.setValue($0.value, forHTTPHeaderField: $0.field) })
        descriptor.headers?.forEach({ request.setValue($0.value, forHTTPHeaderField: $0.field) })

        if let params = descriptor.parameters, let encoding = descriptor.encoding {
            request.httpBody = encoding.encode(params)
        }

        authorization?.authorize(&request)

        return request
    }
    
    /// Method which constructs result URL for request to be sent
    ///
    /// - Parameters:
    ///   - endpoint: object containing info about path to resource on remote location
    ///   - versioned: object containing software versioning info
    /// - Returns: URL object to resource on remote location
    open func constructURL(_ endpoint: Endpoint, versioned: Path? = nil) -> URL {
        var resultPath = endpoint.path
        if let version = versioned {
            resultPath = version + resultPath
        }
        
        let resultEndpoint = Endpoint(resultPath, queryItems: endpoint.queryItems)
        return baseURL.appending(resultEndpoint)
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
    ///   - error: An error object that indicates why the request failed, or nil if the request was successful. Apple doc states that error will be returned in the NSURLErrorDomain
    /// - Returns: Tuple with response data and url response
    open func validate(data: Data?, response: URLResponse?, error: Error?, errorHandler: DetailedErrorHandler?) -> (result: Response<Data>, response: HTTPURLResponse?) {
        if let error = error as? URLError {
            return (Response.failure(error), nil)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            return (Response.failure(NetworkError.emptyResponse), nil)
        }
        
        let statusCode = httpResponse.statusCode
        
        guard acceptableHTTPCodes.contains(statusCode) else {
            let status = NetworkError.HTTPError(statusCode)
            if let hander = errorHandler {
                let detailed = hander.detailedError(from: data, httpStatus: status)
                return (Response.failure(detailed), httpResponse)
            }
            return (Response.failure(status), httpResponse)
        }
        
        guard let data = data else {
            return (Response.failure(NetworkError.emptyResponse), httpResponse)
        }
        return (Response.success(data), httpResponse)
    }
    
    deinit {
        urlSession.invalidateAndCancel()
    }
    
    open func retryIfNeeded(_ request: URLRequest, result: Response<Data>, retry: @escaping () -> Void, completion: @escaping () -> Void) {
        if let retrier = retrier, case let Response.failure(error) = result {
            retrier.shouldRetry(request, with: error) { shouldRetry in
                shouldRetry ? retry() : completion()
            }
        } else {
            completion()
        }
    }
}
