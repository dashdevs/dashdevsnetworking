//
//  MediaParamsMultipartBuilder.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

public struct MediaParamsMultipartBuilder: MultipartBuilder {
    struct EncodingCharacters {
        static let crlf = "\r\n"
    }
    
    public typealias ParamsType = MediaParameters
    
    public func append(_ params: [MediaParameters], to request: inout URLRequest) {
        let boundary = "Boundary-\(UUID().uuidString)"
        guard let boundaryPrefix = "--\(boundary)\(EncodingCharacters.crlf)".data(using: .utf8) else { return }
        guard let boundarySuffix = "--\(boundary)--\(EncodingCharacters.crlf)".data(using: .utf8) else { return }
        guard let crlf = EncodingCharacters.crlf.data(using: .utf8) else { return }
        let data = NSMutableData()
        params.forEach { mediaParameters in
            data.append(boundaryPrefix)
            
            data.append(crlf)
        }
        data.append(boundarySuffix)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = data as Data
    }
}
