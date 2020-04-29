//
//  UnauthorisedRequestRetrierTests.swift
//  DashdevsNetworking_Tests
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import XCTest
@testable import DashdevsNetworking

class UnauthorisedRequestRetrierTests: XCTestCase {
    var networkClient: NetworkClient?
    var retrier: UnauthorisedRequestRetrier?
    
    override func setUp() {
        super.setUp()
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.protocolClasses = [MockURLProtocol.self]
        retrier = UnauthorisedRequestRetrier()
        networkClient = NetworkClient(URL(string: "http://test.com")!,
                                      sessionConfiguration: sessionConfiguration,
                                      retrier: retrier)
    }
    
    override func tearDown() {
        super.tearDown()
        networkClient = nil
        retrier = nil
    }
    
    func testOneSuccessedRequest() {
        let requestDescriptor = MockRequestDescriptor(duration: 1)
        var retryCount = 0
        let authorization = BearerTokenAuth(MockUnauthorizedCredential)
        networkClient?.authorization = authorization
        retrier?.credential = authorization.bearerToken
        retrier?.renewCredential = { success, failure in
            let authorization = BearerTokenAuth(MockAuthorizedCredential)
            self.networkClient?.authorization = authorization
            success(authorization.bearerToken)
            retryCount += 1
        }
        
        let expectation = XCTestExpectation()
        
        networkClient?.load(requestDescriptor, handler: { result, response in
            XCTAssertNotNil(response)
            XCTAssert(response!.statusCode == MockAuthenticationSuccessCode)
            XCTAssert(retryCount == 1)
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 30)
    }
}
