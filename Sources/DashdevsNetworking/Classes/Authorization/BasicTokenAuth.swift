//
//  BasicTokenAuth.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

/// This struct is used for updating URLRequest with basic token authorization
public struct BasicTokenAuth: Authorization {
    /// Token without **Basic** prefix
    public let token: String
    
    /// Token with **Basic** prefix
    public let basicToken: String
    
    public init(_ token: String) {
        self.token = token
        self.basicToken = "\(AuthorizationConstants.basic) \(token)"
    }
    
    /// Adding **Authorization** header to URLRequest
    public func authorize(_ request: inout URLRequest) {
        let authHeader = HTTPHeader(field: AuthorizationConstants.key, value: basicToken)
        request.setValue(authHeader.value, forHTTPHeaderField: authHeader.field)
    }
}
