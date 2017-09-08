//
//  Facebook.swift
//  Postify
//
//  Created by Afiq Hamdan on 8/2/17.
//  Copyright © 2017 Cliqers. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit

typealias completionHandler = (Dictionary<String, Any>) -> ()
typealias failure = (Error?) -> ()


class FacebookAPI: NSObject, FBSDKGraphRequestConnectionDelegate {
    
    class func currentFBAccessToken() -> String {
        let defaults = UserDefaults.standard
        let accessToken = defaults.object(forKey: "fbtoken") as? String
        
        return accessToken!
    }
    
    class func getUserInfo(greetingLabel: UILabel, profileImage: UIImageView) {
    if FacebookAPI.currentFBAccessToken().characters.count > 0  {
        let params = ["fields": "id,name,email"]
        FBSDKGraphRequest(graphPath: "me", parameters: params).start(completionHandler: { (connection, result, error) in
            if error == nil {
                if let result = result as? [String: Any] {
                    guard let name = result["name"] as? String else {return}
                        DispatchQueue.main.async {
                            let greetingMessage = "Welcome, \(name)"
                            greetingLabel.text = greetingMessage

                            let imageURL = "http://graph.facebook.com/\(result["id"]!)/picture?type=large" as String
                            if let url = URL(string: imageURL) {
                                let data = try? Data(contentsOf: url)
                                profileImage.image = UIImage(data: data!)
                                profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
                                profileImage.layer.masksToBounds = true
                                profileImage.layer.borderWidth = 3.0
                                profileImage.layer.borderColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1).cgColor
                            }
                    }
                }
        } else {
            print("pwned")
        }
        })
    }
    }
    
    class func getUserPagesLikes(params dict: Dictionary<String, Any>, handler completionBlock: @escaping completionHandler, failure: @escaping failure) {
        
        FBSDKGraphRequest(graphPath: "me/likes", parameters: dict, httpMethod: "GET").start { (connection, result, error) in
            if error == nil {
                DispatchQueue.main.async {
                    if let fbPageLikestResultDict = result as? [String:Any] {
                        completionBlock(fbPageLikestResultDict)
                    }
                }
            } else {
                failure(error)
            }
        }
        
    }
    
    class func getVideosFromPages(params dict: Dictionary<String, Any>, id: String, completionBlock: @escaping completionHandler, failure: @escaping failure) {
        
        let path = "\(id)/videos?"
        FBSDKGraphRequest(graphPath: path, parameters: dict, httpMethod: "GET").start { (connection, result, error) in
            DispatchQueue.main.async {
                if error == nil {
                    DispatchQueue.main.async {
                        if let videos = result as? [String: Any] {
                            completionBlock(videos)
                        }
                    }
                } else {
                    failure(error)
                }
            }
        }
    }
    
    
    
    // get the likes, shared and comment count for video or post https://stackoverflow.com/questions/16358366/facebook-graph-api-comment-count/36997725#36997725
    //put this function in cellforrow
    class func getTotalCountForVideos(params dict: Dictionary<String, Any>, postID: String, completionBlock: @escaping completionHandler, failure: @escaping failure) {
       
        let postIDPath = "\(postID)/"
        FBSDKGraphRequest(graphPath: postIDPath, parameters: dict, httpMethod: "GET").start { (connection, result, error) in
            DispatchQueue.main.async {
                if error == nil {
                    DispatchQueue.main.async {
                        if let totalCount = result as? [String: Any] {
                            completionBlock(totalCount)
                        }
                    }
                } else {
                    failure(error)
                }
            }
        }
    }
    
    //https://stackoverflow.com/questions/35611241/share-a-video-to-facebook
    class func uploadVideoOnFacebookAsPages(videoURL: String, pageName: String) {
        
        // to upload from URL need to use url, if from video library need to use nsdata
        
        FBSDKGraphRequest(graphPath: "me/accounts", parameters: ["fields": "access_token,name,id"], httpMethod: "GET").start(completionHandler: { (connection, result, error) in
            if error != nil {
                print("error getting the fb page admin data")
            } else {
                guard let aaa = result as? Dictionary<String, Any> else {return}
                guard let accountsArray = aaa["data"] as? Array<Any> else {return}
                for dict in accountsArray {
                    let accountsDict = dict as! NSDictionary
                    if accountsDict["name"] as! String == pageName {
                        print("accounts name: \(String(describing: accountsDict["name"]))")
                        let pageAccessToken = accountsDict["access_token"]! as! String
                        print("account token: \(String(describing: pageAccessToken))")
                        let pageID = accountsDict["id"]! as! String
                        print("page id: \(String(describing: pageID))")


                        var pathURL: URL
                        var videoData: Data
                        pathURL = URL(string: videoURL)!
                        do {
                            videoData = try Data(contentsOf: pathURL)
                            print(videoData)
                            var strDesc : String
                            strDesc = ""
                            let videoObject: [String : Any] = ["title": "Testing yoooo", "description": strDesc, "file_url": pathURL]
                //            self.view!.isUserInteractionEnabled = false
                
                            //for fb pages need to use page access token, personal acc don't need
                            
                            FBSDKGraphRequest(graphPath: "\(pageID)/videos", parameters: videoObject, tokenString: pageAccessToken, version: nil, httpMethod: "POST").start(completionHandler: { (connection, result, error) in
                                if error != nil {
                                    NSLog("Error")
                                    
                                }
                                else {
                                    NSLog("Success")
                                }
                            })
                            } catch {
                            print(error)
                        }
                        
                    }
                }
            }
        })
    }
    
    class func uploadVideoOnFacebookAsIndividual(videoURL: String) {
        
        // to upload from URL need to use url, if from video library need to use nsdata
        
        var pathURL: URL
        var videoData: Data
        pathURL = URL(string: videoURL)!
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
            connection.timeout = 30
            connection.delegate = self as! FBSDKGraphRequestConnectionDelegate
            connection.add(uploadVideoRequest, completionHandler: { (connection, result, error) in
                if error != nil {
                    NSLog("Error")
                }
                else {
                    NSLog("Success")
                }
            })
            connection.start()
            
        } catch {
            print(error)
        }
    }

    class func getFacebookPages(completionBlock: @escaping completionHandler, failure: @escaping failure)  {
       
        let getAllPagesRequest = FBSDKGraphRequest(graphPath: "me/accounts", parameters: ["fields": "access_token,name,id"], httpMethod: "GET")
        let connection = FBSDKGraphRequestConnection()
        connection.timeout = 30
        connection.delegate = self as! FBSDKGraphRequestConnectionDelegate
        connection.add(getAllPagesRequest) { (connection, result, error) in
            if error != nil {
                print("error getting the fb page admin data")
                failure(error)
            } else {
                guard let aaa = result as? Dictionary<String, Any> else {return}
                guard let accountsArray = aaa["data"] as? Array<Any> else {return}
                for dict in accountsArray {
                    let accountsDict = dict as! NSDictionary
                    completionBlock(accountsDict as! Dictionary<String, Any>)
                }
            }

        }
        connection.start()
        
    }
    
    func requestConnectionWillBeginLoading(_ connection: FBSDKGraphRequestConnection!) {
        print("begin uploading video to wall")
    }
    
    func requestConnection(_ connection: FBSDKGraphRequestConnection!, didSendBodyData bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int) {
        print("upload percent reached: " + String(Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)))
    }
}
