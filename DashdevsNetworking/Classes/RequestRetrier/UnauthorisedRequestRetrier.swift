//
//  UnauthorisedRequestRetrier.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

public typealias SuccessRenewHandler = (String) -> Void
public typealias FailureRenewHandler = (Bool) -> Void

/// This class is responsible for authentication credentials renewing process
open class UnauthorisedRequestRetrier: RequestRetrier {
    
    /// Authentication information request header field name
    public let credentialHeaderField: String
    
    /// Authentication information unit
    open var credential: String?
    
    /// Queue which stores requests to retry
    open var queue = SafeQueue()
    
    /// Closure which is called when authentication credentials renewing process finishes
    open var renewCredential: ((@escaping SuccessRenewHandler, @escaping FailureRenewHandler) -> Void)?
    
    private lazy var successRenewHandler: SuccessRenewHandler = { [weak self] credential in
        self?.credential = credential
        self?.queue.fullfill(with: true)
    }
    
    private lazy var failureRenewHandler: FailureRenewHandler = { [weak self] needsToClearCredential in
        if needsToClearCredential { self?.credential = nil }
        self?.queue.fullfill(with: false)
    }
    
    public init(credentialHeaderField: String = "Authorization") {
        self.credentialHeaderField = credentialHeaderField
    }
        
    private func addToQueue(requestRetryCompletion: @escaping RequestRetryCompletion) {
        if queue.add(requestRetryCompletion: requestRetryCompletion) == 1 {
            renewCredential?(successRenewHandler, failureRenewHandler)
        }
    }
    
    /// Method checks whether request contains authentication credentials or not
    /// - Parameter request: request to check credentials containment
    open func isCredentialEqual(to request: URLRequest) -> Bool {
        if let currentCred = credential, let receivedCred = request.value(forHTTPHeaderField: credentialHeaderField) {
            return currentCred == receivedCred
        } else {
            return false
        }
    }
    
    // MARK: - RequestRetrier protocol implementation
    
    public func shouldRetry(_ request: URLRequest, with error: Error, completion: @escaping RequestRetryCompletion) {
        guard let error = error as? NetworkError.HTTPError else {
            completion(false)
            return
        }
        switch error {
        case .unautorized:
            if isCredentialEqual(to: request) {
                addToQueue(requestRetryCompletion: completion)
            } else {
                completion(true)
            }
        default:
            completion(false)
        }
    }
}
