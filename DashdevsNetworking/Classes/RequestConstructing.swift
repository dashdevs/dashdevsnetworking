//
//  RequestConstructing.swift
//  DashdevsNetworking
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

public enum MIMEType: String {
    case applicationJSON = "application/json"
    case plainText = "text/plain"
}

/// This struct describes mechanism which allows the client and the server to pass additional information with the request or the response.
public struct HTTPHeader {
    let field: String
    let value: String
}

extension HTTPHeader {
    
    /// Factory property which returns pre-defined JSON header used to define request body content
    static var jsonContent: HTTPHeader {
        return HTTPHeader(field: "Content-Type", value: MIMEType.applicationJSON.rawValue)
    }
    
    /// Factory property which returns pre-defined plain text header used to define request body content
    static var textContent: HTTPHeader {
        return HTTPHeader(field: "Content-Type", value: MIMEType.plainText.rawValue)
    }
    
    static var acceptJSON: HTTPHeader {
        return HTTPHeader(field: "Accept", value: MIMEType.applicationJSON.rawValue)
    }
    
    static var acceptText: HTTPHeader {
        return HTTPHeader(field: "Accept", value: MIMEType.plainText.rawValue)
    }

}

/// This structure describes request to resource using HTTP protocol
public struct URLRequestComponents {
    
    /// Requested resource locator
    public let url: URL
    
    /// HTTP method of request
    public var method: HTTPMethod
    
    /// Headers of particular request
    public var headers: [HTTPHeader]
    
    /// Binary data that is contained in body of request
    public var body: Data?
    
    /// Read-only property which constructs URLRequest from filled fields
    public var request: URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        headers.forEach({ urlRequest.setValue($0.value, forHTTPHeaderField: $0.field) })
        
        return urlRequest
    }
    
    /// Constructor method for requesting resource representation
    ///
    /// - Parameters:
    ///   - url: resource URL
    ///   - method: HTTP method to use
    public init(url: URL, method: HTTPMethod = .get, headers: [HTTPHeader] = []) {
        self.url = url
        self.method = method
        self.headers = headers
    }
}

public extension URLRequestComponents {
    
    /// Constructor method for submitting an entity to the specified resource
    ///
    /// - Parameters:
    ///   - url: resource URL
    ///   - params: parameters to send in request body
    ///   - method: HTTP method to use
    init<E: Encodable>(url: URL, params: E, method: HTTPMethod = .post, headers: [HTTPHeader] = []) {
        self.url = url
        self.method = method
        let encoding = ParamEncoding<E>.json()
        self.body = encoding.encode(params)
        self.headers = [HTTPHeader.jsonContent] + headers
    }
}
