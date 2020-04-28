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
/// - delete: Method requests server to delete resource identified by URI
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public enum MIMEType: String {
    case applicationJSON = "application/json"
    case plainText = "text/plain"
    case multipartFormData = "multipart/form-data"
}

/// This struct describes mechanism which allows the client and the server to pass additional information with the request or the response.
public struct HTTPHeader {
    let field: String
    let value: String
    
    public init(field: String, value: String) {
        self.field = field
        self.value = value
    }
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
    
    /// Factory property which returns pre-defined multipart form data header used to define request body content
    static func multipartFormData(with boundary: String) -> HTTPHeader {
        return HTTPHeader(field: "Content-Type", value: "\(MIMEType.multipartFormData.rawValue); boundary=\(boundary)")
    }
    
    /// Factory property which returns pre-defined header for accepting JSON response type
    static var acceptJSON: HTTPHeader {
        return HTTPHeader(field: "Accept", value: MIMEType.applicationJSON.rawValue)
    }
    
    /// Factory property which returns pre-defined header for accepting plain text response type
    static var acceptText: HTTPHeader {
        return HTTPHeader(field: "Accept", value: MIMEType.plainText.rawValue)
    }

}
