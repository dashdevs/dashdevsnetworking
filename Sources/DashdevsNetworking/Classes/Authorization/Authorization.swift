//
//  Authorization.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

public struct AuthorizationConstants {
    public static let key = "Authorization"
    public static let bearer = "Bearer"
}

/// This protocol declare method for updating URLRequest with authorization parameters
public protocol Authorization {
    func authorize(_ request: inout URLRequest)
}
