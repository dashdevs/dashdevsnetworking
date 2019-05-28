//
//  Response.swift
//  URLSessionWrapper
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

/// This parametrized struct is used for parsing server data to specific type
public struct Deserializator<A> {
    /// Parsing callback, may throw if parsing fails
	public let parse: (Data) throws -> A
    
    public init(_ parse: @escaping (Data) throws -> A) {
        self.parse = parse
    }
}

public extension Deserializator where A: Decodable {
    /// Factory method which returns pre-defined object for parsing JSON content
    ///
    /// - Returns: object for parsing JSON content
	static func json() -> Deserializator {
        return Deserializator({ data in
			try JSONDecoder().decode(A.self, from: data)
		})
	}
}

public extension Deserializator where A == String {
    
    /// Factory method which returns pre-defined object for parsing plain text content
    ///
    /// - Returns: object for parsing plain text content
    static func plainText() -> Deserializator {
        return Deserializator({ data in
            guard let result = String(data: data, encoding: .utf8) else {
                throw NetworkError.Deserialisation.convertingFailed
            }
            return result
        })
    }
}

/// Result-like parametrised enum describing response from server
///
/// - success: Request succeeded and have produced data attached as associated value
/// - failure: Request failed and have error attached as associated value
public enum Response<A> {
    case success(A)
    case failure(Error)
}

public extension Response {
    
    /// Method for converting Response of one type to another
    ///
    /// - Parameter f: A mapping closure
    /// - Returns: Response object of type B
    func map<B>(_ f: @escaping (A) throws -> B) -> Response<B> {
        switch self {
        case let .success(res):
            do {
                let res = try f(res)
                return .success(res)
            } catch {
                return .failure(error)
            }

        case let .failure(error):
            return .failure(error)
        }
    }
}

