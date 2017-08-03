//
//  TestViewController.swift
//  Postify
//
//  Created by Afiq Hamdan on 8/3/17.
//  Copyright © 2017 Cliqers. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Facebook.getUserInfo(greetingLabel: greetingLabel, profileImage: profilePic)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsetsMake(85, 0, 0, 0)
        
        let params = ["fields": "about,name,created_time,picture", "limit": "3"]
        Facebook.getUserPagesLikes(params: params, handler: { (userData) in
            print("facebook pages: \(userData)")
        }) { (error) in
            print("cannot get FB pages: \(String(describing: error))")
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Hellow"
        cell.detailTextLabel?.text = "Worrrldd"
        
        return cell
    }

}
