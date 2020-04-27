//
//  MultipartBuilder.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

/// This struct is used for updating URLRequest with multipart data for MediaParameters info
public struct MultipartBuilder {
    struct EncodingCharacters {
        static let crlf = "\r\n"
    }
    
    public func append(_ params: [MediaParameters], to request: inout URLRequest) {
        let boundary = "Boundary-\(UUID().uuidString)"
        guard let boundaryPrefix = "--\(boundary)\(EncodingCharacters.crlf)".data(using: .utf8) else { return }
        guard let boundarySuffix = "--\(boundary)--\(EncodingCharacters.crlf)".data(using: .utf8) else { return }
        guard let crlf = EncodingCharacters.crlf.data(using: .utf8) else { return }
        let data = NSMutableData()
        params.forEach { mediaParameters in
            data.append(boundaryPrefix)
            
            var contentDisposition = "Content-Disposition: form-data; name=\"\(mediaParameters.name)\""
            if let fileName = mediaParameters.fileName {
                contentDisposition.append("; filename=\"\(fileName)\"")
            }
            contentDisposition.append(EncodingCharacters.crlf)
            guard let contentDispositionData = contentDisposition.data(using: .utf8) else { return }
            data.append(contentDispositionData)
            
            if let mimeType = mediaParameters.mimeType, let contentType = "Content-Type: \(mimeType)\(EncodingCharacters.crlf)".data(using: .utf8) {
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
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = data as Data
    }
}
