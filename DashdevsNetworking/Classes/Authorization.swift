//
//  Authorization.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

public protocol Authorization {
    func authorize(_ request: inout URLRequest)
}

public struct BearerTokenAuth: Authorization {
    public let token: String
    
    public init(_ token: String) {
        self.token = "Bearer \(token)"
    }
    
    public func authorize(_ request: inout URLRequest) {
        request.addValue(token, forHTTPHeaderField: "Authorization")
    }
}

public extension URLRequest {
    mutating func authorize(authorization: Authorization?) {
        authorization?.authorize(&self)
    }
}
