//
//  MultipartFileParameters.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

/// Struct which is used to describe media parameters (e.g. video or image) for multipart requests
/// - fileURL:  The URL of the file whose content will be encoded into the multipart form data.
/// - name:     The name to associate with the data in the `Content-Disposition` HTTP header.
/// - fileName: The filename to associate with the data in the `Content-Disposition` HTTP header.
/// - mimeType: The MIME type to associate with the data content type in the `Content-Type` HTTP header.
public struct MultipartFileParameters {
    public let fileURL: URL
    public let name: String
    public let fileName: String
    public let mimeType: String
    
    public init(fileURL: URL, name: String, fileName: String, mimeType: String) {
        self.fileURL = fileURL
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }
}
