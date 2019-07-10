//
//  BearerTokenAuth.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

public struct BearerTokenAuth: Authorization {
    public let token: String
    
    public init(_ token: String) {
        self.token = token
    }
    
    public func authorize(_ requestComponents: inout URLRequestComponents) {
        let authHeader = HTTPHeader(field: "Authorization", value: "Bearer \(token)")
        requestComponents.headers.append(authHeader)
    }
}
