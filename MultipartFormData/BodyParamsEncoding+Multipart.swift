//
//  BodyParamsEncoding+Multipart.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

public extension BodyParamEncoding where A == MultipartFileParameters {
    static var multipart: BodyParamEncoding {
        let boundaryBuilder = BoundaryBuilder()
        return BodyParamEncoding({ encodable -> Data? in
            let contentBuilder = MultipartContentBuilder(name: encodable.name, fileName: encodable.fileName, mimeType: encodable.mimeType)
            guard let crlf = EncodingCharacters.crlf.data(using: .utf8) else { return nil }
            do {
                var data = Data()
                data.append(try boundaryBuilder.buildPrefix())
                data.append(try contentBuilder.buildContentDisposition())
                data.append(try contentBuilder.buildContentType())
                data.append(crlf)
                data.append(try Data(contentsOf: encodable.fileURL, options: []))
                data.append(crlf)
                data.append(try boundaryBuilder.buildSuffix())
                return data
            } catch {
                return nil
            }
        }, headers: [HTTPHeader.multipartFormData(with: boundaryBuilder.boundary)])
    }
}
