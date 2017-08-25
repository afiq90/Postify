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


class Facebook: NSObject {
    
    class func currentFBAccessToken() -> String {
        let defaults = UserDefaults.standard
        let accessToken = defaults.object(forKey: "fbtoken") as? String
        
        return accessToken!
    }
    
    class func getUserInfo(greetingLabel: UILabel, profileImage: UIImageView) {
    if Facebook.currentFBAccessToken().characters.count > 0  {
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
    
}
