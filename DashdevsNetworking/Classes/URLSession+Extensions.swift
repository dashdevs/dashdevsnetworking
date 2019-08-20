//
//  URLSessionWrapper.swift
//  DashdevsNetworking
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
    
    func request<Descriptor: RequestDescriptor>(base: URL, descriptor: Descriptor) -> URLRequest where Descriptor.Parameters: Encodable {
        let url = base.appending(descriptor.path)
        var request = URLRequest(url: url)
        request.httpMethod = descriptor.method.rawValue
        
        if let params = descriptor.parameters, let encoding = descriptor.encoding {
            encoding.headers.forEach({ request.setValue($0.value, forHTTPHeaderField: $0.field) })
            request.httpBody = encoding.encode(params)
        }
        
        descriptor.response.headers.forEach({ request.setValue($0.value, forHTTPHeaderField: $0.field) })
        descriptor.headers.forEach({ request.setValue($0.value, forHTTPHeaderField: $0.field) })
        
        return request
    }
    
    func request<Descriptor: RequestDescriptor>(base: URL, descriptor: Descriptor) -> URLRequest where Descriptor.Resource: Decodable {
        let url = base.appending(descriptor.path)
        var request = URLRequest(url: url)
        request.httpMethod = descriptor.method.rawValue
        descriptor.headers.forEach({ request.setValue($0.value, forHTTPHeaderField: $0.field) })
        
        return request
    }
    
    func load<Descriptor: RequestDescriptor>(_ baseURL: URL, descriptor: Descriptor, handler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask
    where Descriptor.Resource: Decodable {
        let request = self.request(base: baseURL, descriptor: descriptor)
        return dataTask(with: request, completionHandler: handler)
    }

    func send<Descriptor: RequestDescriptor>(_ baseURL: URL, descriptor: Descriptor, handler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask
        where Descriptor.Parameters: Encodable {
        let request = self.request(base: baseURL, descriptor: descriptor)
        return uploadTask(with: request, from: request.httpBody!)
    }    
}
