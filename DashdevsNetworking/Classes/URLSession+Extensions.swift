//
//  URLSessionWrapper.swift
//  URLSessionWrapper
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

extension URLSession {
    /// This method should be used for loading data from server
    ///
    /// - Parameters:
    ///   - descriptor: parameter describing request
    ///   - deserialise: parameter describing how response will be parsed
    ///   - handler: The completion handler to call when the load request and response data parsing is complete
    /// - Returns: The new session data task
    public func load(_ descriptor: URLRequestComponents, handler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return dataTask(with: descriptor.request, completionHandler: handler)
    }

    /// This method should be used for uploading data to server
    ///
    /// - Parameters:
    ///   - descriptor: parameter describing request
    ///   - handler: The completion handler to call when request and response data parsing is complete
    /// - Returns: The new session upload task
    public func send(_ descriptor: URLRequestComponents, handler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionUploadTask {
        return uploadTask(with: descriptor.request, from: descriptor.body, completionHandler: handler)
    }
}
