//
//  PagesViewController.swift
//  Postify
//
//  Created by Afiq Hamdan on 8/4/17.
//  Copyright © 2017 Cliqers. All rights reserved.
//

import UIKit

class PagesViewController: UIViewController {
    
    @IBOutlet weak var pageID: UILabel!
    
    var pageIDValue: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        pageID.text = pageIDValue
        print("page id: \(pageIDValue)")
        
//        let params = ["fields": "description,source,thumbnails.limit(1)", "limit": "1"]
//        Facebook.getVideosFromPages(params: params, id: pageIDValue, completionBlock: { (result) in
//            print("videos from page: \(result)")
//        }) { (error) in
//            print("error again")
//        }
        
        let videoCountParams = ["fields": "shares,likes.limit(0).summary(true),comments.limit(0).summary(true)"]
        FacebookAPI.getTotalCountForVideos(params: videoCountParams, postID: "331481044571_1649904411699312", completionBlock: { (result) in
            print("video total count: \(result)")
        }) { (error) in
            print("hello error")
        }

    }

    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
