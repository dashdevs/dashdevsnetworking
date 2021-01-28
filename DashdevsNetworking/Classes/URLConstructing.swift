//
//  URLConstructing.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

public struct Path {
    var components: [String]
    
    public init(_ components: [String]) {
        self.components = components
    }
    
    var rendered: String {
        return "/" + components.joined(separator: "/")
    }
}

public extension Path {    
    static func + (left: Path, right: Path) -> Path {
        return Path(left.components + right.components)
    }
}

/// This struct describes endpoint - end of communication channel
public struct Endpoint {
    
    /// Component, consisting of a sequence of path segments separated by a slash
    let path: Path
    
    /// Query items are basically key-value pairs
    let queryItems: [URLQueryItem]
    
    public init(path: String, queryItems: [URLQueryItem] = []) {
        let components = path.components(separatedBy: "/")
        self.path = Path(components)
        self.queryItems = queryItems
    }
    
    public init(_ path: Path, queryItems: [URLQueryItem] = []) {
        self.path = path
        self.queryItems = queryItems
    }
}

public extension URL {
    
    /// This initialiser returns non-optional URL object. If passed string is not valid URL exception is thrown
    ///
    /// - Parameter string: initialising URL parameter
    init(staticString string: StaticString) {
        guard let url = URL(string: "\(string)") else {
            preconditionFailure("Invalid static URL string: \(string)")
        }
        
        self = url
    }
    
    func appending(_ endpoint: Endpoint) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.path = endpoint.path.rendered
        if !endpoint.queryItems.isEmpty {
            components?.queryItems = endpoint.queryItems
        }
        
        guard let url = components?.url else {
            preconditionFailure("Incorrect url!")
        }
        return url
    }
}

/// This struct describes way to encode parameters in http request body
public struct BodyParamEncoding<BodyParameters> {
    
    /// Encoding parameters callback, may return nil if encoding fails
    let encode: (BodyParameters) -> Data?
    
    /// Headers that describe format of encoding result
    let headers: [HTTPHeader]
    
    public init(_ encode: @escaping (BodyParameters) -> Data?, headers: [HTTPHeader]) {
        self.encode = encode
        self.headers = headers
    }
}

public extension BodyParamEncoding where BodyParameters: Encodable {
    
    /// Factory method which returns pre-defined object for encoding JSON parameters
    ///
    /// - Returns: object for encoding parameters
    static var json: BodyParamEncoding {
        return BodyParamEncoding({ encodable -> Data? in
            try? JSONEncoder().encode(encodable)
        }, headers: [HTTPHeader.jsonContent])
    }
}
