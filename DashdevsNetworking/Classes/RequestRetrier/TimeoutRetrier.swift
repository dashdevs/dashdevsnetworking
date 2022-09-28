//
//  PlainViewController.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

open class TimeoutRetrier: RequestRetrier {

    open var onRetry: (() -> Void)? = nil
    
    public init() {}
    
    public func shouldRetry(_ request: URLRequest, with error: Error, completion: @escaping RequestRetryCompletion) {
        guard let error = error as? NetworkError.HTTPError else {
            completion(false)
            return
        }
        
        switch error {
        case .timeout:
            onRetry?()
            completion(true)
        default:
            completion(false)
        }
    }
}
