//
//  ItunesResults.swift
//  DashdevsNetworking_Example
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation
import DashdevsNetworking

struct ItunesResults: Decodable {
    let results: [ItunesItem]
}

struct ItunesItem: Decodable {
    let artistName: String
    let collectionName: String
    let previewUrl: URL
    let trackName: String?
}

struct AuthCodeModel: Decodable {
}

struct AuthEmailModel: Encodable {
    let email: String
    let source: String
}

struct AuthByEmailDescriptor: RequestDescriptor {
    typealias Resource = AuthCodeModel
    typealias Parameters = AuthEmailModel
    
    private struct Constants {
        static let authSource = "IosApp"
    }
    
    var path: Endpoint
    var method: HTTPMethod
    var response: Deserializator<AuthCodeModel>
    var parameters: AuthEmailModel?
    var headers: [HTTPHeader]
    var encoding: ParamEncoding<AuthEmailModel>?
    
    init(email: String) {
        parameters = AuthEmailModel(email: email, source: "")
        path = Endpoint(path: "/auth/email")
        method = .post
        response = Deserializator<AuthCodeModel>.json
        headers = []
        encoding = .json
    }
}
