//
//  TestViewController.swift
//  Postify
//
//  Created by Afiq Hamdan on 8/3/17.
//  Copyright © 2017 Cliqers. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    struct tableViewIdentifiers {
        static let pagesCell = "PagesCell"
    }
    
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var pagesArray: [String] = []
    var name: String = ""
    var about: String = ""
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Facebook.getUserInfo(greetingLabel: greetingLabel, profileImage: profilePic)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let params = ["fields": "about,name,created_time,picture", "limit": "3"]
        Facebook.getUserPagesLikes(params: params, handler: { (userData) in
            //guard let pagesArrays = userData["data"] as? Array<Any> else {return}
            guard let pagesArrays = userData["data"] as? Array<Any> else {return}
          
            //loop thru array and get the dict
            for dic in pagesArrays {
                let data = dic as! NSDictionary
                self.name = data["name"]! as! String
                self.about = data["about"] as! String
                print("name: \(data["name"]!)")
                print("about: \(data["about"]!)")
                print("dictionary: \(dic)")
            }
            
        }) { (error) in
            print("cannot get FB pages: \(String(describing: error))")
        }
        
        //Add the pagesResultCell nib
        let cellnib = UINib(nibName: tableViewIdentifiers.pagesCell, bundle: nil)
        tableView.register(cellnib, forCellReuseIdentifier: tableViewIdentifiers.pagesCell)
        tableView.rowHeight = 80
        
    }

}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewIdentifiers.pagesCell, for: indexPath) as! PagesCell
        
        
        return cell
        
    }
    
}
