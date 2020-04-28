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

struct ItunesRequestDescriptor: RequestDescriptor {
    typealias BodyParameters = Void
    typealias Resource = ItunesResults
    
    var path: Endpoint {
        return Endpoint(path: "/search", queryItems: [URLQueryItem(name: "media", value: "music"),
                                                      URLQueryItem(name: "entity", value: "song"),
                                                      URLQueryItem(name: "term", value: "aaron smith")])
    }
    
    var method: HTTPMethod { return .get }
    var response: Deserializator<Resource> = .json
}

struct AuthCodeModel: Decodable {
}

struct AuthEmailModel: Encodable {
    let email: String
    let source: String
}

struct AuthByEmailDescriptor: RequestDescriptor {
    typealias Resource = AuthCodeModel
    typealias BodyParameters = AuthEmailModel
    
    private struct Constants {
        static let authSource = "IosApp"
    }
    
    var path: Endpoint
    var method: HTTPMethod
    var response: Deserializator<AuthCodeModel>
    var parameters: AuthEmailModel?
    var encoding: ParamEncoding<AuthEmailModel>?
    
    init(email: String) {
        parameters = AuthEmailModel(email: email, source: "")
        path = Endpoint(path: "/post")
        method = .post
        response = Deserializator<AuthCodeModel>.json
        encoding = .json
    }
}
