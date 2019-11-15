//
//  PetitionTableViewController.swift
//  JSONCodables
//
//  Created by Prakhar Prakash Bhardwaj on 15/11/19.
//  Copyright © 2019 Prakhar Prakash Bhardwaj. All rights reserved.
//

import UIKit

class PetitionTableViewController: UITableViewController {
    
    var petetions = [Result]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestToJson()
    }
    
    func requestToJson() {
        
        let urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
            }
        }
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petetion.self, from: json) {
            petetions = jsonPetitions.results
            print(jsonPetitions.metadata.responseInfo.status)
            tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petetions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PetitionTableViewCell = (tableView.dequeueReusableCell(withIdentifier: "PetitionTableViewCell") as! PetitionTableViewCell)
        
        let petitionIndex = petetions[indexPath.row]
        cell.id.text = petitionIndex.id
        cell.title.text = petitionIndex.title
        cell.body.text = petitionIndex.body
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
