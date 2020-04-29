//
//  MultipartViewController.swift
//  DashdevsNetworking_Example
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import UIKit
import DashdevsNetworking
import Photos

class MultipartViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // http://ptsv2.com/t/5qsb7-1588148738 - it's place where you can see that your request was successfully send
    
    let networkClient = NetworkClient(URL(string: "http://ptsv2.com")!)
    
    @IBAction func uploadImage() {
        processPhotoLibraryPermission { [weak self] in
            guard let strongSelf = self else { return }
            let picker = UIImagePickerController()
            picker.delegate = strongSelf
            picker.sourceType = .savedPhotosAlbum
            strongSelf.present(picker, animated: true)
        }
    }
    
    func uploadImage(with url: URL) {
        let fileParams = MultipartFileParameters(fileURL: url, name: "file", fileName: "image", mimeType: "image/jpeg")
        let requestDescriptor = MultipartRequestDescriptor(parameters: fileParams)
        networkClient.send(requestDescriptor) { result, response in
            
        }
    }
}

extension MultipartViewController {
    private func processPhotoLibraryPermission(onAuthorized: @escaping () -> Void) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    if status == PHAuthorizationStatus.authorized {
                        onAuthorized()
                    }
                }
            }
        case .authorized: onAuthorized()
        default: return
        }
    }
}
