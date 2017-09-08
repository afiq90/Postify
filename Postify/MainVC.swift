//
//  MainVC.swift
//  Postify
//
//  Created by Afiq Hamdan on 8/25/17.
//  Copyright © 2017 Cliqers. All rights reserved.
//

import UIKit
import Lottie

class MainVC: UITableViewController {
    
    struct tableViewIdentifiers {
        static let pagesCell = "PagesResultCell"
    }
    
    var pages: [FBPages] = []
    let animationView = LOTAnimationView(name: "loading.json")


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //loading lottie animation start
        animationView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        animationView.center = view.center
        
        animationView.loopAnimation = true
        animationView.contentMode = .scaleAspectFill
        animationView.animationSpeed = 0.5
        
        // Applying UIView animation
        let minimizeTransform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        animationView.transform = minimizeTransform
        UIView.animate(withDuration: 3.0, delay: 0.0, options: [.repeat, .autoreverse], animations: {
            self.animationView.transform = CGAffineTransform.identity
        }, completion: nil)
        
        view.addSubview(animationView)
        
        animationView.play()
        
        //tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        pages = []
        
        let params = ["fields": "about,created_time,link,name,username,website,fan_count,picture"]
        FacebookAPI.getUserPagesLikes(params: params, handler: { (userData) in
            
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
                self.animationView.pause()
                self.animationView.removeFromSuperview()
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
            let pagesVC = segue.destination as! PagesVC
            let defaults = UserDefaults.standard
            let pageID = defaults.object(forKey: "pageID") as? String
            pagesVC.pageIDValue = pageID!
        }
    }

}
