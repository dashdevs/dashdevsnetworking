//
//  URLConstructing.swift
//  URLSessionWrapper
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

/// This struct describes endpoint - end of communication channel
public struct Endpoint {
    
    /// Path that will be
    let path: String
    
    /// Query items are basically key-value pairs
    let queryItems: [URLQueryItem]
    
    public init(path: String, queryItems: [URLQueryItem] = []) {
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
    
    func appendingEndpoint(_ endpoint: Endpoint) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.path = endpoint.path
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
public struct ParamEncoding<A> {
    
    /// Encoding parameters callback, may return nil if encoding fails
    let encode: (A) -> Data?
}

public extension ParamEncoding where A: Encodable {
    
    /// Factory method which returns pre-defined object for encoding JSON parameters
    ///
    /// - Returns: object for encoding parameters
    static func json() -> ParamEncoding {
        return ParamEncoding(encode: { enc -> Data? in
            try? JSONEncoder().encode(enc)
        })
    }
}
