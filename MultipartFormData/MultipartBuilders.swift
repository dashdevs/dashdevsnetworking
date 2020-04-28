//
//  MultipartBuilders.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

public struct EncodingCharacters {
    static let crlf = "\r\n"
}

public struct BoundaryBuilder {
    public let boundary = "Boundary-\(UUID().uuidString)"
    
    public func buildPrefix() -> Data? {
        return "--\(boundary)\(EncodingCharacters.crlf)".data(using: .utf8)
    }
    
    public func buildSuffix() -> Data? {
        return "--\(boundary)--\(EncodingCharacters.crlf)".data(using: .utf8)
    }
}

public struct MultipartContentDescriptionBuilder {
    public let name: String
    public let fileName: String?
    public let mimeType: String?
    
    public init(name: String, fileName: String? = nil, mimeType: String? = nil) {
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }

    public func buildContentDisposition() -> Data? {
        var contentDisposition = "Content-Disposition: form-data; name=\"\(name)\""
        if let fileName = fileName {
            contentDisposition.append("; filename=\"\(fileName)\"")
        }
        contentDisposition.append(EncodingCharacters.crlf)
        return contentDisposition.data(using: .utf8)
    }
    
    public func buildContentType() -> Data? {
        guard let mimeType = mimeType else { return nil }
        return "Content-Type: \(mimeType)\(EncodingCharacters.crlf)".data(using: .utf8)
    }
}

/// This struct is used for updating URLRequest with multipart data for MediaParameters info
public struct MultipartBuilder {
    public let boundaryBuilder = BoundaryBuilder()
    
    public func append(_ params: [MultipartFileParameters], to request: inout URLRequest) {
        guard let boundaryPrefix = boundaryBuilder.buildPrefix() else { return }
        guard let boundarySuffix = boundaryBuilder.buildSuffix() else { return }
        guard let crlf = EncodingCharacters.crlf.data(using: .utf8) else { return }
        var data = Data()
        params.forEach { mediaParameters in
            let contentBuilder = MultipartContentDescriptionBuilder(name: mediaParameters.name,
                                                                    fileName: mediaParameters.fileName,
                                                                    mimeType: mediaParameters.mimeType)
            guard let contentDisposition = contentBuilder.buildContentDisposition() else { return }
            guard let contentType = contentBuilder.buildContentType() else { return }
            data.append(boundaryPrefix)
            data.append(contentDisposition)
            data.append(contentType)
            data.append(crlf)
            do {
                data.append(try Data(contentsOf: mediaParameters.fileURL, options: []))
            } catch {
                return
            }
            data.append(crlf)
        }
        data.append(boundarySuffix)
        let header = HTTPHeader.multipartFormData(with: boundaryBuilder.boundary)
        request.setValue(header.value, forHTTPHeaderField: header.field)
        request.httpBody = data
    }
}
