//
//  TestViewController.swift
//  Postify
//
//  Created by Afiq Hamdan on 8/3/17.
//  Copyright © 2017 Cliqers. All rights reserved.
//

import UIKit
import Dispatch
import SDWebImage

class MainViewController: UIViewController {
    
    struct tableViewIdentifiers {
        static let pagesCell = "PagesResultCell"
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
        
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        Facebook.getUserInfo(greetingLabel: greetingLabel, profileImage: profilePic)
        
        pages = []
        
        let params = ["fields": "about,name,created_time,picture", "limit": "5"]
        Facebook.getUserPagesLikes(params: params, handler: { (userData) in
            
            guard let pagesArrays = userData["data"] as? Array<Any> else {return}
            
            for dict in pagesArrays {
                
                let fbPages = FBPages()
                let pagesDict = dict as! NSDictionary
                print("hoho: \(pagesDict)")
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
    
        
        print("access token: \(Facebook.currentFBAccessToken())")
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

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewIdentifiers.pagesCell, for: indexPath) as! PagesResultCell
        
        let pagesData = pages[indexPath.row]
        cell.pagesName.text = pagesData.name
       // cell.pagesFans.text = "pagesData.pagesTotalFans"
        
        let imageUrl = URL(string: pagesData.pictureLink)
        cell.pagesImage.sd_setImage(with: imageUrl!, placeholderImage: UIImage(named: "placeholder"), options: .continueInBackground, progress: nil
            , completed: nil)

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //save page ID into UserDefaults
        let pagesData = pages[indexPath.row]
        let userDefaults = UserDefaults.standard
        userDefaults.set(pagesData.id, forKey: "pageID")
        userDefaults.synchronize()
       
        performSegue(withIdentifier: "pagesVC", sender: self)
    
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if pages.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
    
}
