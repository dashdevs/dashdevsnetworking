//
//  ItunesResults.swift
//  DashdevsNetworking_Example
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation
import DashdevsNetworking

// TODO: - ItunesResult model

struct ItunesResult: Decodable {
    let results: [ItunesItem]
}

struct ItunesItem: Decodable {
    let artistName: String
    let collectionName: String
    let previewUrl: URL
    let trackName: String?
}

// TODO: - ItunesErrorResult model

struct ItunesErrorResult: Decodable {
    let errorMessage: String?
    let queryParameters: QueryParametersErrorResults?
}

struct QueryParametersErrorResults: Decodable {
    let output: String?
    let callback: String?
    let country: String?
    let limit: String?
    let term: String?
    let lang: String?
}

// TODO: - ItunesRequestDescriptor

struct ItunesRequestDescriptor: RequestDescriptor {
    typealias BodyParameters = Void
    typealias Resource = ItunesResult
    typealias ResourceError = ItunesErrorResult
    
    var path: Endpoint {
        return Endpoint(path: "search", queryItems: [URLQueryItem(name: "media", value: "music"),
                                                     URLQueryItem(name: "entity", value: "song"),
                                                     URLQueryItem(name: "term", value: "aaron smith")])
    }
    
    var method: HTTPMethod { return .get }
    var response: Deserializator<Resource> = .json
    var responseError: Deserializator<ResourceError>? = .json
}

// TODO: - ItunesErrorRequestDescriptor

struct ItunesErrorRequestDescriptor: RequestDescriptor {
    typealias BodyParameters = Void
    typealias Resource = ItunesResult
    typealias ResourceError = ItunesErrorResult
    
    var path: Endpoint {
        return Endpoint(path: "search", queryItems: [URLQueryItem(name: "media", value: "music"),
                                                     URLQueryItem(name: "entity", value: "song1"),
                                                     URLQueryItem(name: "term", value: "aaron smith")])
    }
    
    var method: HTTPMethod { return .get }
    var response: Deserializator<Resource> = .json
    var responseError: Deserializator<ResourceError>? = .json
}

// TODO: - ItunesWithoutResourceErrorRequestDescriptor

struct ItunesWithoutResourceErrorRequestDescriptor: RequestDescriptor {
    typealias BodyParameters = Void
    typealias Resource = ItunesResult
    typealias ResourceError = Void
    
    var path: Endpoint {
        return Endpoint(path: "search", queryItems: [URLQueryItem(name: "media", value: "music"),
                                                     URLQueryItem(name: "entity", value: "song1"),
                                                     URLQueryItem(name: "term", value: "aaron smith")])
    }
    
    var method: HTTPMethod { return .get }
    var response: Deserializator<Resource> = .json
}

// TODO: - AuthCodeModel model

struct AuthCodeModel: Decodable {
}

struct AuthEmailModel: Encodable {
    let email: String
    let source: String
}

// TODO: - AuthByEmailRequestDescriptor

struct AuthByEmailRequestDescriptor: RequestDescriptor {
    typealias Resource = AuthCodeModel
    typealias BodyParameters = AuthEmailModel
    typealias ResourceError = Void
    
    private struct Constants {
        static let authSource = "IosApp"
    }
    
    var path: Endpoint
    var method: HTTPMethod
    var response: Deserializator<AuthCodeModel>
    var parameters: AuthEmailModel?
    var encoding: BodyParamEncoding<AuthEmailModel>?
    
    init(email: String) {
        parameters = AuthEmailModel(email: email, source: "")
        path = Endpoint(path: "post")
        method = .post
        response = Deserializator<AuthCodeModel>.json
        encoding = .json
    }
}
