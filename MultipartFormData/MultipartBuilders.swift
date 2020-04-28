//
//  MultipartBuilders.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

enum MultipartBuildersError: Error {
    case canNotCreateBoundary
    case canNotCreateContentDisposition
    case mimeTypeIsMissing
    case canNotCreateContentType
}

public struct EncodingCharacters {
    static let crlf = "\r\n"
}

public struct BoundaryBuilder {
    public let boundary = "Boundary-\(UUID().uuidString)"
    
    public func buildPrefix() throws -> Data {
        guard let prefix = "--\(boundary)\(EncodingCharacters.crlf)".data(using: .utf8) else {
            throw MultipartBuildersError.canNotCreateBoundary
        }
        return prefix
    }
    
    public func buildSuffix() throws -> Data {
        guard let suffix = "--\(boundary)--\(EncodingCharacters.crlf)".data(using: .utf8) else {
            throw MultipartBuildersError.canNotCreateBoundary
        }
        return suffix
    }
}

public struct MultipartContentBuilder {
    public let name: String
    public let fileName: String?
    public let mimeType: String?
    
    public init(name: String, fileName: String? = nil, mimeType: String? = nil) {
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }

    public func buildContentDisposition() throws -> Data {
        var contentDisposition = "Content-Disposition: form-data; name=\"\(name)\""
        if let fileName = fileName {
            contentDisposition.append("; filename=\"\(fileName)\"")
        }
        contentDisposition.append(EncodingCharacters.crlf)
        if let data = contentDisposition.data(using: .utf8) {
            return data
        } else {
            throw MultipartBuildersError.canNotCreateContentDisposition
        }
    }
    
    public func buildContentType() throws -> Data {
        guard let mimeType = mimeType else { throw MultipartBuildersError.mimeTypeIsMissing }
        if let data = "Content-Type: \(mimeType)\(EncodingCharacters.crlf)".data(using: .utf8) {
            return data
        } else {
            throw MultipartBuildersError.canNotCreateContentType
        }
    }
}
