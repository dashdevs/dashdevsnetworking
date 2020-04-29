//
//  MockRequestDescriptor.swift
//  DashdevsNetworking_Tests
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import DashdevsNetworking

struct MockRequestDescriptor: RequestDescriptor {
    typealias BodyParameters = Void
    typealias Resource = Void
    
    let duration: Int
    
    let path: Endpoint = Endpoint(path: "authorization")
    let method: HTTPMethod = .get
    let response: Deserializator<Resource> = .none
    var headers: [HTTPHeader]? {
        return [HTTPHeader(field: MockDurationKey, value: String(duration))]
    }
}
