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
    
    func testTwoUnauthorizedRequests() {
        let firstRequestDescriptor = MockRequestDescriptor(duration: 100)
        let secondRequestDescriptor = MockRequestDescriptor(duration: 300)
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
        expectation.expectedFulfillmentCount = 2
        
        networkClient?.load(firstRequestDescriptor, handler: { result, response in
            XCTAssertNotNil(response)
            XCTAssert(response!.statusCode == MockAuthenticationSuccessCode)
            XCTAssert(retryCount == 1)
            expectation.fulfill()
        })
        
        networkClient?.load(secondRequestDescriptor, handler: { result, response in
            XCTAssertNotNil(response)
            XCTAssert(response!.statusCode == MockAuthenticationSuccessCode)
            XCTAssert(retryCount == 1)
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 30)
    }
    
    func testManyUnauthorizedRequests() {
        var retryCount = 0
        
        let authorization = BearerTokenAuth(MockUnauthorizedCredential)
        networkClient?.authorization = authorization
        retrier?.credential = authorization.bearerToken
        retrier?.renewCredential = { success, failure in
            retryCount += 1
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                let authorization = BearerTokenAuth(MockAuthorizedCredential)
                self.networkClient?.authorization = authorization
                success(authorization.bearerToken)
            }
        }
        
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 10
        expectation.assertForOverFulfill = true
        
        (1...10).forEach { index in
            let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(index * 100)
            DispatchQueue.global().asyncAfter(deadline: deadline) {
                let requestDescriptor = MockRequestDescriptor(duration: 100)
                
                self.networkClient?.load(requestDescriptor, handler: { result, response in
                    XCTAssertNotNil(response)
                    XCTAssert(response!.statusCode == MockAuthenticationSuccessCode)
                    XCTAssert(retryCount == 1)
                    expectation.fulfill()
                })
            }
        }

        wait(for: [expectation], timeout: 30)
    }
    
    func testFailureRenewWithCleanCred() {
        let requestDescriptor = MockRequestDescriptor(duration: 1)
        let authorization = BearerTokenAuth(MockUnauthorizedCredential)
        networkClient?.authorization = authorization
        retrier?.credential = authorization.bearerToken
        retrier?.renewCredential = { success, failure in
            failure(true)
        }
        
        let expectation = XCTestExpectation()
        
        networkClient?.load(requestDescriptor, handler: { result, response in
            XCTAssertNil(self.retrier?.credential)
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 30)
    }
    
    func testFailureRenewWithoutCleanCred() {
        let requestDescriptor = MockRequestDescriptor(duration: 1)
        let authorization = BearerTokenAuth(MockUnauthorizedCredential)
        networkClient?.authorization = authorization
        retrier?.credential = authorization.bearerToken
        retrier?.renewCredential = { success, failure in
            failure(false)
        }
        
        let expectation = XCTestExpectation()
        
        networkClient?.load(requestDescriptor, handler: { result, response in
            XCTAssertNotNil(self.retrier?.credential)
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 30)
    }
    
    func testIsCredentialEqualToRequest() {
        let requestDescriptor = MockRequestDescriptor(duration: 1)
        let authorization = BearerTokenAuth(MockUnauthorizedCredential)
        networkClient?.authorization = authorization
        do {
            let request = try XCTUnwrap(networkClient?.makeRequest(from: requestDescriptor))
            let retrier = try XCTUnwrap(self.retrier)
            XCTAssertFalse(retrier.isCredentialEqual(to: request))
            
            retrier.credential = authorization.bearerToken
            XCTAssert(retrier.isCredentialEqual(to: request))
        } catch {
            XCTFail()
        }
    }
    
    func testShouldRetry() {
        let requestDescriptor = MockRequestDescriptor(duration: 1)
        do {
            let request = try XCTUnwrap(networkClient?.makeRequest(from: requestDescriptor))
            let expectation = XCTestExpectation()
            expectation.expectedFulfillmentCount = 2
            
            let serverError = NetworkError.HTTPError.client
            retrier?.shouldRetry(request, with: serverError) { shouldRetry in
                XCTAssertFalse(shouldRetry)
                expectation.fulfill()
            }
            
            let unknownError = NSError(domain: "com.network.unknown", code: 0, userInfo: nil)
            retrier?.shouldRetry(request, with: unknownError) { shouldRetry in
                XCTAssertFalse(shouldRetry)
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 30)
        } catch {
            XCTFail()
        }
    }
}
