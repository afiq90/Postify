//
//  ViewController.swift
//  Postify
//
//  Created by Cliqers on 01/08/2017.
//  Copyright © 2017 Cliqers. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Dispatch

class LoginViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if FBSDKAccessToken.current() != nil {
            //perform segue to mainVC
            performSegue(withIdentifier: "mainVC", sender: self)

        } else {
            loginToFB()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    
        blurEffect()
    }
    
    func loginToFB() {
        let loginButton = FBSDKLoginButton()
        loginButton.delegate = self
        loginButton.center = view.center
        loginButton.readPermissions = ["public_profile","email","user_friends","user_likes"]
        //,"manage_pages","publish_pages" <-- need to access for write permissions
        view.addSubview(loginButton)
    }
    
    
    // MARK - UINavigationController
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mainVC" {
            let mainVC = segue.destination as! MainViewController
        }
    }
    
    func blurEffect() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.8
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
    }

    
}

extension LoginViewController: FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        let defaults = UserDefaults.standard
        defaults.set(FBSDKAccessToken.current().tokenString, forKey: "fbtoken")
        defaults.synchronize()
        
        performSegue(withIdentifier: "mainVC", sender: self)

    
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logout")
    }
}
