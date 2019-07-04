//
//  Response.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

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

