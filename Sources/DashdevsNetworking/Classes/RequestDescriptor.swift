//
//  RequestDescriptor.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

/// Protocol which is used to describe request to remote location
public protocol RequestDescriptor {
    associatedtype BodyParameters
    associatedtype Resource
    associatedtype ResourceError
    
    var path: Endpoint { get }
    var method: HTTPMethod { get }
    var encoding: BodyParamEncoding<BodyParameters>? { get }
    var headers: [HTTPHeader]? { get }
    var response: Deserializator<Resource> { get }
    var responseError: Deserializator<ResourceError>? { get }
    var parameters: BodyParameters? { get }
    var versionPath: Path? { get }
}

public extension RequestDescriptor {
    var versionPath: Path? { nil }
    var headers: [HTTPHeader]? { nil }
    var encoding: BodyParamEncoding<BodyParameters>? { nil }
    var responseError: Deserializator<ResourceError>? { nil }
    var parameters: BodyParameters? { nil }
}
