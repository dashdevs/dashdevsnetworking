//
//  NetworkClient.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

import Combine

/// This general enum describes place where you need to display logs
///
/// - console: Display in console
public enum DisplayNetworkDebugLog {
    case console
}

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
    public var displayNetworkDebugLog: DisplayNetworkDebugLog?
    
    /// Constructor method
    ///
    /// - Parameters:
    ///   - base: base URL to use
    ///   - sessionConfiguration: configuration of URL session to use
    ///   - authorization: authorization strategy to use
    public init(_ base: URL, sessionConfiguration: URLSessionConfiguration = .default, authorization: Authorization? = nil, retrier: RequestRetrier? = nil,  displayNetworkDebugLog: DisplayNetworkDebugLog? = nil) {
        self.baseURL = base
        self.urlSession = URLSession(configuration: sessionConfiguration)
        self.authorization = authorization
        self.retrier = retrier
        self.displayNetworkDebugLog = displayNetworkDebugLog
    }
    
    /// Method which should be used to load information from remote location
    ///
    /// - Parameters:
    ///   - descriptor: object that describes outgoing request to remote location
    ///   - retryCount: number of request retries
    ///   - handler: block of code to call after url request completes
    ///   - taskHandler: block of code to return current task, like downloading a specific resource, performed in a URL session
    public func load<Descriptor: RequestDescriptor>(_ descriptor: Descriptor, retryCount: UInt = 1, handler: @escaping (Response<Descriptor.Resource, Descriptor.ResourceError>, HTTPURLResponse?) -> (), taskHandler: ((URLSessionTask) -> Void)? = nil) {
        let request = makeRequest(from: descriptor)

        let task = urlSession.dataTask(with: request) { (data, response, error) in
            let validated = self.validate(data: data, response: response, error: error)
            self.retryIfNeeded(request, retryCount: retryCount, result: validated.result, retry: {
                self.load(descriptor, retryCount: retryCount - 1, handler: handler, taskHandler: taskHandler)
            }, completion: {
                DispatchQueue.main.async { handler(validated.result.map(descriptor.response.parse, descriptor.responseError?.parse), validated.response) }
            })
        }
        task.resume()
        taskHandler?(task)
    }
    
    @available(iOS 13.0.0, *)
    /// Method which should be used to load information from remote location using swift concurrency
    /// 
    /// - Parameters:
    ///   - descriptor: object that describes outgoing request to remote location
    ///   - retryCount: number of request retries
    /// - Returns: Tuple of objects  with Response and HTTPURLResponse types
    public func load<Descriptor: RequestDescriptor>(_ descriptor: Descriptor, retryCount: UInt = 1) async -> (Response<Descriptor.Resource, Descriptor.ResourceError>, HTTPURLResponse?) {
        var data: Data?
        var response: URLResponse?
        var error: NSError?

        let request = makeRequest(from: descriptor)
        do {
            let resultData = try await urlSession.data(for: request)
            data = resultData.0
            response = resultData.1
        } catch let resultError {
            error = resultError as NSError
        }
        
        let validated = self.validate(data: data, response: response, error: error)
        
        if let result = await self.retryIfNeeded(descriptor, request, retryCount: retryCount, result: validated.result) {
            return result
        } else {
            return (validated.result.map(descriptor.response.parse, descriptor.responseError?.parse), validated.response)
        }
    }
    
    /// Method which should be used to send information to remote location
    ///
    /// - Parameters:
    ///   - descriptor: object that describes outgoing request to remote location
    ///   - retryCount: number of request retries
    ///   - handler: block of code to call after url request completes
    ///   - taskHandler: block of code to return current task, like downloading a specific resource, performed in a URL session
    public func send<Descriptor: RequestDescriptor>(_ descriptor: Descriptor, retryCount: UInt = 1, handler: @escaping (Response<Descriptor.Resource, Descriptor.ResourceError>, HTTPURLResponse?) -> (), taskHandler: ((URLSessionTask) -> Void)? = nil) {
        
        let request = makeRequest(from: descriptor)
        
        // If http body will be nil - upload task will be cancelled
        let task = urlSession.uploadTask(with: request, from: request.httpBody ?? Data()) { (data, response, error) in
            let validated = self.validate(data: data, response: response, error: error)
            self.retryIfNeeded(request, retryCount: retryCount, result: validated.result, retry: {
                self.send(descriptor, retryCount: retryCount - 1, handler: handler, taskHandler: taskHandler)
            }, completion: {
                DispatchQueue.main.async { handler(validated.result.map(descriptor.response.parse, descriptor.responseError?.parse), validated.response) }
            })
        }
        task.resume()
        taskHandler?(task)
    }
    
    @available(iOS 13.0.0, *)
    /// Method which should be used to send information to remote location
    ///
    /// - Parameters:
    ///   - descriptor: object that describes outgoing request to remote location
    ///   - retryCount: number of request retries
    /// - Returns: Tuple of objects  with Response and HTTPURLResponse types
    public func send<Descriptor: RequestDescriptor>(_ descriptor: Descriptor, retryCount: UInt = 1) async -> (Response<Descriptor.Resource, Descriptor.ResourceError>, HTTPURLResponse?) {
        var data: Data?
        var response: URLResponse?
        var error: NSError?
        
        let request = makeRequest(from: descriptor)
        
        do {
            let resultData = try await urlSession.upload(for: request, from: request.httpBody ?? Data())
            data = resultData.0
            response = resultData.1
        } catch let resultError {
            error = resultError as NSError
        }
        
        let validated = self.validate(data: data, response: response, error: error)

        if let result = await self.retryIfNeeded(descriptor, request, retryCount: retryCount, result: validated.result) {
            return result
        } else {
            return (validated.result.map(descriptor.response.parse, descriptor.responseError?.parse), validated.response)
        }
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
        
        NetworkDebugLog.log(with: request, displayNetworkDebugLog: displayNetworkDebugLog)

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
    open func validate(data: Data?, response: URLResponse?, error: Error?) -> (result: Response<Data, Data>, response: HTTPURLResponse?) {
        NetworkDebugLog.log(with: data, response: response, error: error, displayNetworkDebugLog: displayNetworkDebugLog)
        
        if let error = error as? URLError {
            return (Response.failure(data, error), nil)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            return (Response.failure(data, NetworkError.emptyResponse), nil)
        }
        
        let statusCode = httpResponse.statusCode
        
        guard acceptableHTTPCodes.contains(statusCode) else {
            let status = NetworkError.HTTPError(statusCode)
            return (Response.failure(data, status), httpResponse)
        }
        
        guard let data = data else {
            return (Response.failure(nil, NetworkError.emptyResponse), httpResponse)
        }
        return (Response.success(data), httpResponse)
    }
    
    deinit {
        urlSession.invalidateAndCancel()
    }
    
    open func retryIfNeeded(_ request: URLRequest, retryCount: UInt, result: Response<Data, Data>, retry: @escaping () -> Void, completion: @escaping () -> Void) {
        if let retrier = retrier, case let Response.failure(_, error) = result, retryCount != .zero {
            retrier.shouldRetry(request, with: error) { shouldRetry in
                shouldRetry ? retry() : completion()
            }
        } else {
            completion()
        }
    }
    
    @available(iOS 13.0.0, *)
    open func retryIfNeeded<Descriptor: RequestDescriptor>(_ descriptor: Descriptor, _ request: URLRequest, retryCount: UInt, result: Response<Data, Data>) async -> (Response<Descriptor.Resource, Descriptor.ResourceError>, HTTPURLResponse?)? {
        guard let retrier = retrier, case let Response.failure(_, error) = result, retryCount != .zero else { return nil }
        return try? await withCheckedThrowingContinuation { continuation in
            retrier.shouldRetry(request, with: error) { shouldRetry in
                if shouldRetry {
                    Task {
                        continuation.resume(returning: await self.load(descriptor, retryCount: retryCount - 1))
                    }
                } else {
                    continuation.resume(throwing: NetworkError.emptyResponse)
                }
            }
        }
    }
}
