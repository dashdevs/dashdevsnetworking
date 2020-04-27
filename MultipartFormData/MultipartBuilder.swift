//
//  MultipartBuilder.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

/// This protocol declares method for updating URLRequest with multipart form data
public protocol MultipartBuilder {
    associatedtype ParamsType
    func append(_ params: [ParamsType], to request: inout URLRequest)
}
