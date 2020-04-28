//
//  BodyParamsEncoding+Multipart.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

public extension BodyParamEncoding where A == MultipartFileParameters {
    
    /// Factory method which returns pre-defined object for encoding multipart parameters
    ///
    /// - Returns: object for encoding parameters
    static var multipart: BodyParamEncoding {
        let boundaryBuilder = BoundaryBuilder()
        return BodyParamEncoding({ encodable -> Data? in
            let contentBuilder = MultipartContentBuilder(name: encodable.name, fileName: encodable.fileName, mimeType: encodable.mimeType)
            do {
                var data = Data()
                data.append(try boundaryBuilder.buildPrefix())
                data.append(try contentBuilder.buildContentDisposition())
                data.append(try contentBuilder.buildContentType())
                data.append(try EncodingCharacters.crlfData())
                data.append(try Data(contentsOf: encodable.fileURL, options: []))
                data.append(try EncodingCharacters.crlfData())
                data.append(try boundaryBuilder.buildSuffix())
                return data
            } catch {
                return nil
            }
        }, headers: [HTTPHeader.multipartFormData(with: boundaryBuilder.boundary)])
    }
}

public extension BodyParamEncoding where A == [MultipartFileParameters] {
    
    /// Factory method which returns pre-defined object for encoding multipart parameters
    ///
    /// - Returns: object for encoding parameters
    static var multipart: BodyParamEncoding {
        let boundaryBuilder = BoundaryBuilder()
        return BodyParamEncoding({ encodables -> Data? in
            do {
                var data = Data()
                try encodables.forEach { encodable in
                    let contentBuilder = MultipartContentBuilder(name: encodable.name, fileName: encodable.fileName, mimeType: encodable.mimeType)
                    data.append(try boundaryBuilder.buildPrefix())
                    data.append(try contentBuilder.buildContentDisposition())
                    data.append(try contentBuilder.buildContentType())
                    data.append(try EncodingCharacters.crlfData())
                    data.append(try Data(contentsOf: encodable.fileURL, options: []))
                    data.append(try EncodingCharacters.crlfData())
                }
                data.append(try boundaryBuilder.buildSuffix())
                return data
            } catch {
                return nil
            }
        }, headers: [HTTPHeader.multipartFormData(with: boundaryBuilder.boundary)])
    }
}
