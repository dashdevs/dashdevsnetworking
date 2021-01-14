//
//  ViewController.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import UIKit
import DashdevsNetworking

class ViewController: UITableViewController {
    let apiClient1: NetworkClient = NetworkClient(URL(staticString: "https://itunes.apple.com"))
    
    let apiClient2: NetworkClient = NetworkClient(URL(staticString: "https://httpbin.org"))
    
    var items: [ItunesItem] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let authByEmailDescriptor = AuthByEmailDescriptor(email: "email@email.com")
        
        apiClient2.send(authByEmailDescriptor) { (result, _) in
            debugPrint(result)
        }
        
        let itunesRequestErrorDescriptor = ItunesRequestErrorDescriptor()
        apiClient1.load(itunesRequestErrorDescriptor) { (response, _) in
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
        
        let itunesRequestDescriptor = ItunesRequestDescriptor()
        apiClient1.load(itunesRequestDescriptor) { [weak self] (response, _) in
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
