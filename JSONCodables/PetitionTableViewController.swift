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
        self.registerNib()
    }
    
    func registerNib(){
        let nib = UINib(nibName: "PetitionTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "PetitionTableViewCell")
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
        let cell = (tableView.dequeueReusableCell(withIdentifier: "PetitionTableViewCell") as! PetitionTableViewCell)
        
        let petitionIndex = petetions[indexPath.row]
        cell.id.text = petitionIndex.id
        cell.title.text = petitionIndex.title
        cell.body.text = petitionIndex.body
        
        cell.button.addTarget(self, action: #selector(self.buttonPressed), for: .touchUpInside)
        cell.button.tag = indexPath.row
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}

extension PetitionTableViewController {
    
    @objc func buttonPressed(sender:UIButton){
        let vc = self.storyboard?.instantiateViewController(identifier: "PetitionDetailViewController") as! PetitionDetailViewController
        let petitionIndex = petetions[sender.tag]

        vc.pId = petitionIndex.id
        vc.pIdTitle = petitionIndex.title.components(separatedBy: " ")[0]
        vc.pCreated = petitionIndex.created
        vc.pDeadline = petitionIndex.deadline
        vc.pStatus = petitionIndex.status.rawValue
            
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false, completion: nil)
    }
}

