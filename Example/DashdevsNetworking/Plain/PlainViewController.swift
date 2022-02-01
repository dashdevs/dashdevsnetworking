//
//  PlainViewController.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import UIKit
import DashdevsNetworking

final class PlainViewController: UITableViewController {
    private let apiClient1: NetworkClient = NetworkClient(URL(staticString: "https://itunes.apple.com"))
    private let apiClient2: NetworkClient = NetworkClient(
        URL(staticString: "https://httpbin.org"),
        displayNetworkDebugLog: .console)
    private let apiClient3: NetworkClient = NetworkClient(
        URL(staticString: "https://itunes.apple.com"),
        retrier: TimeoutRetrier(),
        displayNetworkDebugLog: .console)
    
    private var items: [ItunesItem] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstExample()
        secondExample()
        thirdExample()
        fourthExample()
        
        timeoutExample()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "cellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
        }
        
        let item = items[indexPath.row]
        
        cell?.textLabel?.text = item.artistName + " - " + (item.trackName ?? "")
        cell?.detailTextLabel?.text = item.collectionName
        
        return cell!
    }    
}

// MARK: - Examples

extension PlainViewController {
    private func firstExample() {
        let requestDescriptor = AuthByEmailRequestDescriptor(email: "email@email.com")

        apiClient2.send(requestDescriptor, retryCount: 3) { (result, _) in
            debugPrint(result)
        }
    }

    private func secondExample() {
        let requestDescriptor = ItunesErrorRequestDescriptor()

        apiClient1.load(requestDescriptor) { (response, _) in
            switch response {
            case let .success(result):
                debugPrint(result.results)
            case .failure(let model, let error):
                if let model = model {
                    debugPrint(model)
                }
                debugPrint(error)
            }
        }
    }

    private func thirdExample() {
        let requestDescriptor = ItunesWithoutResourceErrorRequestDescriptor()

        apiClient1.load(requestDescriptor) { (response, _) in
            switch response {
            case let .success(result):
                debugPrint(result.results)
            case .failure(let model, let error):
                if let model = model {
                    debugPrint(model)
                }
                debugPrint(error)
            }
        }
    }

    private func fourthExample() {
        let requestDescriptor = ItunesRequestDescriptor()

        apiClient1.load(requestDescriptor) { [weak self] (response, _) in
            switch response {
            case let .success(result):
                self?.items = result.results
            case .failure(let model, let error):
                if let model = model {
                    debugPrint(model)
                }
                debugPrint(error)
            }
        }
    }
    
    private func timeoutExample() {
        let requestDescriptor = ItunesRequestDescriptor()

        apiClient3.load(requestDescriptor) { (response, _) in
            switch response {
            case let .success(result):
                debugPrint(result.results)
            case .failure(let model, let error):
                if let model = model {
                    debugPrint(model)
                }
                debugPrint(error)
            }
        }
    }
}
