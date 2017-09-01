//
//  PagesVC.swift
//  Postify
//
//  Created by Afiq Hamdan on 8/25/17.
//  Copyright © 2017 Cliqers. All rights reserved.
//

import UIKit
import Lottie
import FBSDKCoreKit
import FBSDKLoginKit

class PagesVC: UITableViewController {
  
    var pageIDValue: String = ""
    var videoInfoArray: [PagesVideo] = []
    var activityView = UIActivityIndicatorView()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView.center = self.view.center
        self.view.addSubview(activityView)
        activityView.startAnimating()
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       // tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        

        print("page id: \(pageIDValue)")
      
        videoInfoArray = []

        let params = ["fields": "description,source,thumbnails.limit(1)", "limit": "3"]
        Facebook.getVideosFromPages(params: params, id: pageIDValue, completionBlock: { (result) in
            
            guard let videoArrays = result["data"] as? Array<Any> else {return}
            
            for dict in videoArrays {
                
                let videoPagesInfo = PagesVideo()
                let videoDict = dict as! NSDictionary
                
                /*
                 var source = ""
                 var videoTotalLikes = ""
                 var videoTotalShare = ""
                 var videoTotalComment = ""
                 var videoDateCreated = ""
                 var videoThumbnail = ""
                 var videoDescription = ""
                 */

                if let videoDesc = videoDict["description"] {
                    videoPagesInfo.videoDescription = videoDesc as! String
                    print("description: \(videoPagesInfo.videoDescription)")
                }
                

                if let videoSource = videoDict["source"] {
                    videoPagesInfo.source = videoSource as! String
                }
                
                if let videoThumbnail = videoDict["thumbnails"] as? Dictionary<String, Any> {
                    
                    guard let thumbnailArray = videoThumbnail["data"]! as? Array<Any> else {return}
                    
                        let thumbDict = thumbnailArray.first as! Dictionary<String, Any>
                        
                        if let uri = thumbDict["uri"] {
                            videoPagesInfo.videoThumbnail = uri as! String
                        }
                        
                    
//                    for thumbnail in thumbnailArray {
//
//                        let thumbDict = thumbnail as! Dictionary<String, Any>
//
//                        if let uri = thumbDict["uri"] {
//                            videoPagesInfo.videoThumbnail = uri as! String
//                        }
//
//                    }
                   
                    print("video thumbnail: \(videoPagesInfo.videoThumbnail)")

                }
                

                
//                if let pagesPicture = pagesDict.value(forKeyPath: "picture.data.url") {
//                    fbPages.pictureLink = pagesPicture as! String
//                }
//                if let pagesFansTotalCount = pagesDict["fan_count"] {
//                    fbPages.pagesTotalFans = pagesFansTotalCount as! Int
//                }
                self.videoInfoArray.append(videoPagesInfo)
                
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.activityView.stopAnimating()
            }
            
        }) { (error) in
            print("cannot get FB pages: \(String(describing: error))")
        }



    }

    // MARK: - Table view data source

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return videoInfoArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "PagesCell", for: indexPath) as! PagesCell
        
        let videosData = videoInfoArray[indexPath.row]
        
        let videoImageUrl = URL(string: videosData.videoThumbnail)
        cell.videoThumbnail.sd_setImage(with: videoImageUrl!, placeholderImage: UIImage(named: "placeholder"), options: .continueInBackground, progress: nil
            , completed: nil)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if videoInfoArray.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func repostButton(_ sender: UIButton) {
        
        //https://stackoverflow.com/questions/43167275/how-can-i-request-facebook-publish-actions-permission-wfrom-my-swift-app
        if !(FBSDKAccessToken.current().hasGranted("publish_actions")) {
            
            print("Request publish_actions permissions")
            let login: FBSDKLoginManager = FBSDKLoginManager()
            
            login.logIn(withPublishPermissions: ["publish_actions"], from: self) { (result, error) in
                if (error != nil) {
                    print(error!)
                } else if (result?.isCancelled)! {
                    print("Canceled")
                } else if (result?.grantedPermissions.contains("publish_actions"))! {
                    print("permissions granted")
                    
                }
            }
        } else {
            print("publish actions done")
            
            let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.tableView)
            guard let indexPath = self.tableView.indexPathForRow(at: buttonPosition) else {return}
            print("indexpath row: \(indexPath.row)")

            let videosData = videoInfoArray[indexPath.row]
            let videoSourceURL = videosData.source
            print("video source by row: \(videoSourceURL)")
            Facebook.uploadVideoOnFacebookAsPages(videoURL: videoSourceURL)
            
        }
    }

}
