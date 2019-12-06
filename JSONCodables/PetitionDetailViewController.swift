//
//  PetitionDetailViewController.swift
//  JSONCodables
//
//  Created by Prakhar Prakash Bhardwaj on 06/12/19.
//  Copyright © 2019 Prakhar Prakash Bhardwaj. All rights reserved.
//

import UIKit

class PetitionDetailViewController: UIViewController {

    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var idTitle: UILabel!
    @IBOutlet weak var created: UILabel!
    @IBOutlet weak var deadline: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    
    var pId: String = ""
    var pIdTitle: String = ""
    var pCreated: Int = 0
    var pDeadline: Int = 0
    var pStatus: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.id.text = pId
        self.idTitle.text = pIdTitle
        self.created.text = String(pCreated)
        self.deadline.text = String(pDeadline)
        self.status.text = pStatus
    }
    
    @IBAction func dismissScreen(_ sender: UIButton){
        self.dismiss(animated: false) {
            print("Dismiss")
        }
    }
}
