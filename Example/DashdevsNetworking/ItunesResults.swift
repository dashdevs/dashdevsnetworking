//
//  ItunesResults.swift
//  DashdevsNetworking_Example
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation
import DashdevsNetworking

// TODO: - ItunesResults model

struct ItunesResults: Decodable {
    let results: [ItunesItem]
}

struct ItunesItem: Decodable {
    let artistName: String
    let collectionName: String
    let previewUrl: URL
    let trackName: String?
}

// TODO: - ItunesErrorResults model

struct ItunesErrorResults: Decodable {
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
    typealias Parameters = Void
    typealias Resource = ItunesResults
    typealias ResourceError = ItunesErrorResults
    
    var path: Endpoint {
        return Endpoint(path: "search", queryItems: [URLQueryItem(name: "media", value: "music"),
                                                     URLQueryItem(name: "entity", value: "song"),
                                                     URLQueryItem(name: "term", value: "aaron smith")])
    }
    
    var method: HTTPMethod { return .get }
    var response: Deserializator<Resource> = .json
    var responseError: Deserializator<ResourceError> = .json
}

// TODO: - ItunesRequestErrorDescriptor

struct ItunesRequestErrorDescriptor: RequestDescriptor {
    typealias Parameters = Void
    typealias Resource = ItunesResults
    typealias ResourceError = ItunesErrorResults
    
    var path: Endpoint {
        return Endpoint(path: "search", queryItems: [URLQueryItem(name: "media", value: "music"),
                                                     URLQueryItem(name: "entity", value: "song1"),
                                                     URLQueryItem(name: "term", value: "aaron smith")])
    }
    
    var method: HTTPMethod { return .get }
    var response: Deserializator<Resource> = .json
    var responseError: Deserializator<ResourceError> = .json
}

// TODO: - ItunesRequestErrorVoidDescriptor

struct ItunesRequestErrorVoidDescriptor: RequestDescriptor {
    typealias Parameters = Void
    typealias Resource = ItunesResults
    typealias ResourceError = Void
    
    var path: Endpoint {
        return Endpoint(path: "search", queryItems: [URLQueryItem(name: "media", value: "music"),
                                                     URLQueryItem(name: "entity", value: "song1"),
                                                     URLQueryItem(name: "term", value: "aaron smith")])
    }
    
    var method: HTTPMethod { return .get }
    var response: Deserializator<Resource> = .json
    var responseError: Deserializator<ResourceError> = .none
}

// TODO: - AuthCodeModel model

struct AuthCodeModel: Decodable {
}

struct AuthEmailModel: Encodable {
    let email: String
    let source: String
}

// TODO: - AuthByEmailDescriptor

struct AuthByEmailDescriptor: RequestDescriptor {
    typealias Resource = AuthCodeModel
    typealias Parameters = AuthEmailModel
    typealias ResourceError = Void
    
    private struct Constants {
        static let authSource = "IosApp"
    }
    
    var path: Endpoint
    var method: HTTPMethod
    var response: Deserializator<AuthCodeModel>
    var parameters: AuthEmailModel?
    var encoding: ParamEncoding<AuthEmailModel>?
    var responseError: Deserializator<Void>
    
    init(email: String) {
        parameters = AuthEmailModel(email: email, source: "")
        path = Endpoint(path: "post")
        method = .post
        response = Deserializator<AuthCodeModel>.json
        encoding = .json
        responseError = Deserializator<ResourceError>.none
    }
}
