//
//  PlainViewController.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

class TimeoutMockURLProtocol: URLProtocol {
    
    private let mockTimeoutFailureCode = 408
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        let handle: (URLRequest) -> Void = {
            [weak self] request in
            guard let strongSelf = self else { return }
            let response: HTTPURLResponse
            
            response = HTTPURLResponse(
                url: request.url!,
                statusCode: strongSelf.mockTimeoutFailureCode,
                httpVersion: nil,
                headerFields: request.allHTTPHeaderFields)!

            strongSelf.client?.urlProtocol(
                strongSelf,
                didReceive: response,
                cacheStoragePolicy: .notAllowed)
            strongSelf.client?.urlProtocolDidFinishLoading(strongSelf)
        }
        
        if let durationString = request.value(forHTTPHeaderField: MockDurationKey), let duration = Int(durationString) {
            let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(duration)
            DispatchQueue.global().asyncAfter(deadline: deadline) { [weak self] in
                guard let strongSelf = self else { return }
                handle(strongSelf.request)
            }
        } else {
            handle(request)
        }
    }
    
    override func stopLoading() { }
}
