//
//  MainVC.swift
//  Postify
//
//  Created by Afiq Hamdan on 8/25/17.
//  Copyright © 2017 Cliqers. All rights reserved.
//

import UIKit

class MainVC: UITableViewController {
    
    struct tableViewIdentifiers {
        static let pagesCell = "PagesResultCell"
    }
    
    var pages: [FBPages] = []


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        pages = []
        
        let params = ["fields": "about,created_time,link,name,username,website,fan_count,picture", "limit": "10"]
        Facebook.getUserPagesLikes(params: params, handler: { (userData) in
            
            guard let pagesArrays = userData["data"] as? Array<Any> else {return}
            
            for dict in pagesArrays {
                
                let fbPages = FBPages()
                let pagesDict = dict as! NSDictionary
                if let name = pagesDict["name"] {
                    fbPages.name = name as! String
                }
                if let about = pagesDict["about"] {
                    fbPages.about = about as! String
                }
                if let pageID = pagesDict["id"] {
                    fbPages.id = pageID as! String
                }
                if let pagesPicture = pagesDict.value(forKeyPath: "picture.data.url") {
                    fbPages.pictureLink = pagesPicture as! String
                }
                if let pagesFansTotalCount = pagesDict["fan_count"] {
                    fbPages.pagesTotalFans = pagesFansTotalCount as! Int
                }
                self.pages.append(fbPages)
                
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                
            }
            
        }) { (error) in
            print("cannot get FB pages: \(String(describing: error))")
        }

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewIdentifiers.pagesCell, for: indexPath) as! PagesResultCell
        
        let pagesData = pages[indexPath.row]
        cell.pagesName.text = pagesData.name
        cell.pagesFans.text = "\(pagesData.pagesTotalFans)"
        
        let imageUrl = URL(string: pagesData.pictureLink)
        cell.pagesImage.sd_setImage(with: imageUrl!, placeholderImage: UIImage(named: "placeholder"), options: .continueInBackground, progress: nil
            , completed: nil)
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //save page ID into UserDefaults
        let pagesData = pages[indexPath.row]
        let userDefaults = UserDefaults.standard
        userDefaults.set(pagesData.id, forKey: "pageID")
        userDefaults.synchronize()
        
        performSegue(withIdentifier: "pagesVC", sender: self)
        
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if pages.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
    
    // MARK - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pagesVC" {
            let pagesVC = segue.destination as! PagesViewController
            let defaults = UserDefaults.standard
            let pageID = defaults.object(forKey: "pageID") as? String
            pagesVC.pageIDValue = pageID!
        }
    }

}
