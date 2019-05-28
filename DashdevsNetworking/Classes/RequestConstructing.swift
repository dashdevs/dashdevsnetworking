//
//  RequestConstructing.swift
//  URLSessionWrapper
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

/// This enum describes cases that indicate the desired action to be performed for a given resource
///
/// - get: Method requests a representation of the specified resource
/// - post: Method is used to submit an entity to the specified resource
/// - put: Method replaces all current representations of the target resource with the request payload.
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}

/// This struct describes mechanism which allows the client and the server to pass additional information with the request or the response.
public struct HTTPHeader {
    let field: String
    let value: String
}

extension HTTPHeader {
    
    /// Factory method which returns pre-defined JSON header used to define request body content
    ///
    /// - Returns: JSON content header
    static func jsonContent() -> HTTPHeader {
        return HTTPHeader(field: "Content-Type", value: "application/json")
    }
}

/// This structure describes request to resource using HTTP protocol
public struct URLRequestComponents {
    
    /// Requested resource locator
    public let url: URL
    
    /// HTTP method of request
    public var method: HTTPMethod
    
    /// Headers of particular request
    public var headers: [HTTPHeader]?
    
    /// Binary data that is contained in body of request
    public var body: Data?
    
    /// Read-only property which constructs URLRequest from filled fields
    public var request: URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        if let head = headers {
            head.forEach({ urlRequest.setValue($0.value, forHTTPHeaderField: $0.field) })
        }
        
        return urlRequest
    }
    
    /// Constructor method for requesting resource representation
    ///
    /// - Parameters:
    ///   - url: resource URL
    ///   - method: HTTP method to use
    public init(url: URL, method: HTTPMethod = .get) {
        self.url = url
        self.method = method
    }
}

public extension URLRequestComponents {
    
    /// Constructor method for submitting an entity to the specified resource
    ///
    /// - Parameters:
    ///   - url: resource URL
    ///   - params: parameters to send in request body
    ///   - method: HTTP method to use
    init<E: Encodable>(url: URL, params: E, method: HTTPMethod = .post) {
        self.url = url
        self.method = method
        let encoding = ParamEncoding<E>.json()
        self.body = encoding.encode(params)
        self.headers = [HTTPHeader.jsonContent()]
    }
}
