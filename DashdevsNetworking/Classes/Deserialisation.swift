//
//  Deserialisation.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

/// This parametrized struct is used for parsing server data to specific type
public struct Deserializator<A> {
    /// Parsing callback, may throw if parsing fails
    public let parse: (Data) throws -> A
    public let headers: [HTTPHeader]
    
    public init(_ parse: @escaping (Data) throws -> A, headers: [HTTPHeader]) {
        self.parse = parse
        self.headers = headers
    }
}

public extension Deserializator where A: Decodable {
    /// Factory method which returns pre-defined object for parsing JSON content
    ///
    /// - Returns: object for parsing JSON content
    static var json: Deserializator {
        return Deserializator({ data in
            try JSONDecoder().decode(A.self, from: data)
        }, headers: [HTTPHeader.acceptJSON])
    }
}

public extension Deserializator where A == String {
    
    /// Factory method which returns pre-defined object for parsing plain text content
    ///
    /// - Returns: object for parsing plain text content
    static var plainText: Deserializator {
        return Deserializator({ data in
            guard let result = String(data: data, encoding: .utf8) else {
                throw NetworkError.Deserialisation.convertingFailed
            }
            return result
        }, headers: [HTTPHeader.acceptText])
    }
}
