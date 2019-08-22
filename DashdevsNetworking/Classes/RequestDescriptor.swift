//
//  RequestDescriptor.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

/// Protocol which is used to describe request to remote location
public protocol RequestDescriptor {
    associatedtype Parameters
    associatedtype Resource
    
    var path: Endpoint { get }
    var method: HTTPMethod { get }
    var encoding: ParamEncoding<Parameters>? { get }
    var headers: [HTTPHeader] { get }
    var response: Deserializator<Resource> { get }
    var parameters: Parameters? { get }
}
