//
//  TestViewController.swift
//  Postify
//
//  Created by Afiq Hamdan on 8/3/17.
//  Copyright © 2017 Cliqers. All rights reserved.
//

import UIKit
import Dispatch

class MainViewController: UIViewController {
    
    struct tableViewIdentifiers {
        static let pagesCell = "PagesCell"
    }
    
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var pages: [FBPages] = []

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Facebook.getUserInfo(greetingLabel: greetingLabel, profileImage: profilePic)
        
        pages = []
        
        let params = ["fields": "about,name,created_time,picture", "limit": "12"]
        Facebook.getUserPagesLikes(params: params, handler: { (userData) in
            
            guard let pagesArrays = userData["data"] as? Array<Any> else {return}
            
            for dict in pagesArrays {
                
                let fbPages = FBPages()
                let pagesData = dict as! NSDictionary
                if let name = pagesData["name"] {
                    fbPages.name = name as! String
                }
                if let about = pagesData["about"] {
                    fbPages.about = about as! String
                }
                self.pages.append(fbPages)
                
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()

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
        return pages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewIdentifiers.pagesCell, for: indexPath) as! PagesCell
        
        let pagesData = pages[indexPath.row]
        cell.pagesName.text = pagesData.name
        cell.pagesAbout.text = pagesData.about

        return cell
        
    }
    
}
