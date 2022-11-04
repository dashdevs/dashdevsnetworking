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
    
    /// Token with **Bearer** prefix
    public let bearerToken: String
    
    public init(_ token: String) {
        self.token = token
        self.bearerToken = "\(AuthorizationConstants.bearer) \(token)"
    }
    
    /// Adding **Authorization** header to URLRequest
    public func authorize(_ request: inout URLRequest) {
        let authHeader = HTTPHeader(field: AuthorizationConstants.key, value: bearerToken)
        request.setValue(authHeader.value, forHTTPHeaderField: authHeader.field)
    }
}
