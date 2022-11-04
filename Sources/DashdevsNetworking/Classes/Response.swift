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
/// - failure: Request failed and data and error were added as related values
public enum Response<A, B> {
    case success(A)
    case failure(B?, Error)
}

public extension Response {
    
    /// Method for converting Response of one type to another
    ///
    /// - Parameter parsingSuccessClosure: A mapping success closure
    /// - Parameter parsingFailureClosure: A mapping failure closure
    /// - Returns: Response object of types C and D
    func map<C, D>(_ parsingSuccessClosure: @escaping (A) throws -> C, _ parsingFailureClosure: ((B) throws -> D)?) -> Response<C, D> {
        switch self {
        case let .success(res):
            do {
                let res = try parsingSuccessClosure(res)
                return .success(res)
            } catch {
                return .failure(nil, error)
            }
            
        case .failure(let res, let error):
            do {
                guard let res = res, let failureClosure = parsingFailureClosure else {
                    return .failure(nil, error)
                }
                
                let result = try failureClosure(res)
                return .failure(result, error)
            } catch {
                return .failure(nil, error)
            }
        }
    }
}
