//
//  PlainViewController.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import XCTest
@testable import DashdevsNetworking

class TimeoutRequestRetrierTests: XCTestCase {

    var networkClient: NetworkClient?
    var retrier: TimeoutRetrier?
    
    override func setUp() {
        super.setUp()
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.protocolClasses = [TimeoutMockURLProtocol.self]
        retrier = TimeoutRetrier()
        networkClient = NetworkClient(URL(string: "http://test.com")!,
                                      sessionConfiguration: sessionConfiguration,
                                      retrier: retrier)
    }

    override func tearDown() {
        super.tearDown()
        networkClient = nil
        retrier = nil
    }

    func testTimeoutRequestsRetry() throws {
        let requestDescriptor = MockRequestDescriptor(duration: 200)

        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 1
        
        var retryCount = 0
        retrier?.onRetry = {
            retryCount += 1
        }
        
        networkClient?.load(requestDescriptor, retryCount: 3) {
            result, response in
            
            XCTAssertNotNil(response)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30)
        XCTAssert(retryCount == 3)
    }
}
