//
//  MultipartViewController.swift
//  DashdevsNetworking_Example
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import UIKit
import DashdevsNetworking
import Photos

class MultipartViewController: UIViewController {
    // http://ptsv2.com/t/5qsb7-1588148738 - it's place where you can see that your request was successfully send
    
    let networkClient = NetworkClient(URL(string: "http://ptsv2.com")!)
    
    lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .savedPhotosAlbum
        return picker
    }()
    
    @IBAction func uploadImage() {
        processPhotoLibraryPermission {
            self.present(self.imagePicker, animated: true)
        }
    }
    
    func uploadImage(with url: URL) {
        let fileParams = MultipartFileParameters(fileURL: url, name: "file", fileName: "image", mimeType: "image/jpeg")
        let requestDescriptor = MultipartRequestDescriptor(parameters: fileParams)
        networkClient.send(requestDescriptor) { result, response in
            switch result {
            case .success(_):
                print("Multipart File uploaded")
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension MultipartViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let imageURL = info["UIImagePickerControllerImageURL"] as? URL else { return }
        uploadImage(with: imageURL)
        picker.dismiss(animated: true)
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
