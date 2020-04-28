//
//  MultipartFileParameters.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

/// Struct which is used to describe media parameters (e.g. video or image) for multipart requests
/// - fileURL:  The URL of the file whose content will be encoded into the multipart form data.
/// - name:     The name to associate with the data in the `Content-Disposition` HTTP header.
/// - fileName: The filename to associate with the data in the `Content-Disposition` HTTP header.
/// - mimeType: The MIME type to associate with the data content type in the `Content-Type` HTTP header.
public struct MultipartFileParameters {
    let fileURL: URL
    let name: String
    let fileName: String
    let mimeType: String
}
