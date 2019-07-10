//
//  Authorization.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

/// This protocol declare method for updating URLRequestComponents with authorization parameters
public protocol Authorization {
    func authorize(_ requestComponents: inout URLRequestComponents)
}
