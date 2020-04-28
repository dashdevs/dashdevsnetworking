//
//  MultipartBuilders.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

private struct EncodingCharacters {
    static let crlf = "\r\n"
}

public struct BoundaryBuilder {
    public let boundary = "Boundary-\(UUID().uuidString)"
    
    public var boundaryPrefix: Data? {
        return "--\(boundary)\(EncodingCharacters.crlf)".data(using: .utf8)
    }
    
    public var boundarySuffix: Data? {
        return "--\(boundary)--\(EncodingCharacters.crlf)".data(using: .utf8)
    }
}

/// This struct is used for updating URLRequest with multipart data for MediaParameters info
public struct MultipartBuilder {
    public let boundaryBuilder = BoundaryBuilder()
    
    public func append(_ params: [MultipartFileParameters], to request: inout URLRequest) {
        guard let boundaryPrefix = boundaryBuilder.boundaryPrefix else { return }
        guard let boundarySuffix = boundaryBuilder.boundarySuffix else { return }
        guard let crlf = EncodingCharacters.crlf.data(using: .utf8) else { return }
        var data = Data()
        params.forEach { mediaParameters in
            data.append(boundaryPrefix)
            
            var contentDisposition = "Content-Disposition: form-data; name=\"\(mediaParameters.name)\""
            contentDisposition.append("; filename=\"\(mediaParameters.fileName)\"")
            contentDisposition.append(EncodingCharacters.crlf)
            guard let contentDispositionData = contentDisposition.data(using: .utf8) else { return }
            data.append(contentDispositionData)
            
            if let contentType = "Content-Type: \(mediaParameters.mimeType)\(EncodingCharacters.crlf)".data(using: .utf8) {
                data.append(contentType)
            }
            
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
