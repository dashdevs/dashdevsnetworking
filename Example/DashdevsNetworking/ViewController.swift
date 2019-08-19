//
//  ViewController.swift
//  DashdevsNetworking
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import UIKit
import DashdevsNetworking

class ViewController: UITableViewController {
    let apiClient: NetworkClient = NetworkClient(URL(staticString: "https://itunes.apple.com"))
    
    var items: [ItunesItem] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let endpoint = Endpoint(path: "/search", queryItems: [URLQueryItem(name: "media", value: "music"),
                                                              URLQueryItem(name: "entity", value: "song"),
                                                              URLQueryItem(name: "term", value: "aaron smith")])
        
        apiClient.get(endpoint, deserialise: Deserializator<ItunesResults>.json) { (response, _) in
            switch response {
            case let .success(results):
                self.items = results.results
            case let .failure(error):
                print(error)
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
