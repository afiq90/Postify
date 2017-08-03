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

typealias likesCompletionHandler = (Dictionary<String, Any>) -> ()
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
                                profileImage.layer.borderColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
                            }
                    }
                }
        } else {
            print("pwned")
        }
        })
    }
    }
    
    //@{@"fields": @"about,name,created_time,picture",@"limit": @"50", @"after": currentPage}
    class func getUserPagesLikes(params dict:Dictionary<String, Any>, handler completionBlock: @escaping likesCompletionHandler, failure: @escaping failure) {
        
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
    
    
}
