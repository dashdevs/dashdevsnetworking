//
//  Authorization.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

public protocol Authorization {
    func authorize(_ requestComponents: inout URLRequestComponents)
}
