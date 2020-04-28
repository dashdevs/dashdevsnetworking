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
    
    var path: Endpoint { get }
    var method: HTTPMethod { get }
    var encoding: ParamEncoding<BodyParameters>? { get }
    var headers: [HTTPHeader]? { get }
    var response: Deserializator<Resource> { get }
    var parameters: BodyParameters? { get }
    var versionPath: Path? { get }
    var detailedErrorHandler: DetailedErrorHandler? { get }
    var mediaParameters: [MediaParameters]? { get }
}

public extension RequestDescriptor {
    var detailedErrorHandler: DetailedErrorHandler? { return nil }
    var versionPath: Path? { return nil }
    var headers: [HTTPHeader]? { return nil }
    var encoding: ParamEncoding<BodyParameters>? { return nil }
    var parameters: BodyParameters? { return nil }
    var mediaParameters: [MediaParameters]? { return nil }
}
