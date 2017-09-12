//
//  PagesVC.swift
//  Postify
//
//  Created by Afiq Hamdan on 8/25/17.
//  Copyright © 2017 Cliqers. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import CZPicker

class PagesVC: UITableViewController, FBSDKGraphRequestConnectionDelegate {
  
    var pageIDValue: String = ""
    var videoSourceURL: String = ""
    var videoDescription: String = ""
    var activityView = UIActivityIndicatorView()
    var pickerWithImage: CZPickerView?
    var fruitImages = [UIImage]()
    var videoInfoArray: [PagesVideo] = []
    var FBPagesAccount: [PagesAccount] = []
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView.center = self.view.center
        self.view.addSubview(activityView)
        activityView.startAnimating()
        
        
        FBPagesAccount = []
        
        FacebookAPI.getFacebookPages(completionBlock: { (pagesDict) in
            //print("pages dict: \(String(describing: pagesDict["name"]!))")
            let pagesAccount = PagesAccount()
            if let pageName = pagesDict["name"] {
                pagesAccount.pageName = pageName as! String
            }
            self.FBPagesAccount.append(pagesAccount)
            
        }) { (error) in
            print(error)
        }

    }


    override func viewDidLoad() {
        super.viewDidLoad()
        

       // tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        

        print("page id: \(pageIDValue)")
      
        videoInfoArray = []
        
        //no limit video for premium user
        let params = ["fields": "description,source,thumbnails.limit(1)"]
        
        //limit to 10 for standard user
        //let params = ["fields": "description,source,thumbnails.limit(1)", "limit": "3"]

        FacebookAPI.getVideosFromPages(params: params, id: pageIDValue, completionBlock: { (result) in
            
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
        return videoInfoArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "PagesCell", for: indexPath) as! PagesCell
        
        let videosData = videoInfoArray[indexPath.row]
        
        let videoImageUrl = URL(string: videosData.videoThumbnail)
        cell.videoThumbnail.sd_setImage(with: videoImageUrl!, placeholderImage: UIImage(named: "placeholder"), options: .continueInBackground, progress: nil
            , completed: nil)
        cell.pagesDescription.text = videosData.videoDescription
        
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

    @IBAction func downloadButton(_ sender: Any) {
        
       
        
    }
    
    @IBAction func repostButton(_ sender: UIButton) {
    
        //get videoSource URL
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.tableView)
        guard let indexPath = self.tableView.indexPathForRow(at: buttonPosition) else {return}

        let videosData = videoInfoArray[indexPath.row]
        videoSourceURL = videosData.source
        videoDescription = videosData.videoDescription
        
        let picker = CZPickerView(headerTitle: "Pages", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
        picker?.delegate = self
        picker?.dataSource = self
        picker?.needFooterView = true
        picker?.show()
        
    }
    
    func uploadVideoToWall(videoSource: String) {
        var pathURL: URL
        var videoData: Data
        pathURL = URL(string: videoSource)!
        do {
            videoData = try Data(contentsOf: pathURL)
            print(videoData)
            var strDesc : String
            strDesc = "😄🤡😎"
            let videoObject: [String : Any] = ["title": "Testing yoooo", "description": strDesc, "file_url": pathURL]
            //            self.view!.isUserInteractionEnabled = false
            
            //for fb pages need to get page access token, personal acc don't need
            
            let uploadVideoRequest = FBSDKGraphRequest(graphPath: "me/videos", parameters: videoObject, httpMethod: "POST")
            let connection = FBSDKGraphRequestConnection()
            connection.delegate = self
            connection.add(uploadVideoRequest, completionHandler: { (connection, result, error) in
                if error != nil {
                    print("Error: \(String(describing: error))")
                    
                }
                else {
                    print("Success")
                }
            })
            connection.start()
            
        } catch {
            print(error)
        }

    }
    
    func requestConnectionWillBeginLoading(_ connection: FBSDKGraphRequestConnection!) {
        print("begin uploading video to wall")
    }
    
    func requestConnection(_ connection: FBSDKGraphRequestConnection!, didSendBodyData bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int) {
        print("upload percent reached: " + String(Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)))
    }

}

extension PagesVC: CZPickerViewDelegate, CZPickerViewDataSource {
    func czpickerView(_ pickerView: CZPickerView!, imageForRow row: Int) -> UIImage! {
        if pickerView == pickerWithImage {
            return fruitImages[row]
        }
        return nil
    }
    
    func numberOfRows(in pickerView: CZPickerView!) -> Int {
        return FBPagesAccount.count
    }
    
    func czpickerView(_ pickerView: CZPickerView!, titleForRow row: Int) -> String! {
        return FBPagesAccount[row].pageName
    }
    
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int){
        
        let pageName = FBPagesAccount[row].pageName
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        // repost function
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

            FacebookAPI.uploadVideoOnFacebookAsPages(videoURL: self.videoSourceURL, pageName: pageName, description: videoDescription)
            
           // uploadVideoToWall(videoSource: videoSourceURL)
        
        }
    }
    
    func czpickerViewDidClickCancelButton(_ pickerView: CZPickerView!) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @nonobjc func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemsAtRows rows: [AnyObject]!) {
        for row in rows {
            if let row = row as? Int {
                print(FBPagesAccount[row].pageName)
            }
            print(row)
        }
    }
}
