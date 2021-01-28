//
//  MultipartRequestDescriptor.swift
//  DashdevsNetworking_Example
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation
import DashdevsNetworking

struct MultipartRequestDescriptor: RequestDescriptor {
    typealias BodyParameters = MultipartFileParameters
    typealias Resource = Void
    
    let parameters: MultipartFileParameters?

    let path: Endpoint = Endpoint(Path(["t", "5qsb7-1588148738", "post"]))
    let method: HTTPMethod = .post
    let encoding: BodyParamEncoding<MultipartFileParameters>? = .multipart
    let response: Deserializator<Void> = .none
}
