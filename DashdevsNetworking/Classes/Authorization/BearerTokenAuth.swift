//
//  BearerTokenAuth.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

/// This struct is used for updating URLRequest with bearer token authorization
public struct BearerTokenAuth: Authorization {
    /// Token without **Bearer** prefix
    public let token: String
    
    public init(_ token: String) {
        self.token = token
    }
    
    /// Adding **Authorization** header to URLRequest
    public func authorize(_ request: inout URLRequest) {
        let authHeader = HTTPHeader(field: "Authorization", value: "Bearer \(token)")
        request.addValue(authHeader.value, forHTTPHeaderField: authHeader.field)
    }
}
