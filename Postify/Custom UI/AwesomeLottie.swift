//
//  AwesomeLottie.swift
//  Postify
//
//  Created by Afiq Hamdan on 8/28/17.
//  Copyright © 2017 Cliqers. All rights reserved.
//

import Foundation
import UIKit
import Lottie

class AwesomeLottie: NSObject {

    class func lottieLoadingAnimation(view: UIView) {
        let animationView = LOTAnimationView(name: "loading.json")
        animationView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        animationView.center = view.center
        
        animationView.loopAnimation = true
        animationView.contentMode = .scaleAspectFill
        animationView.animationSpeed = 0.5
        
        // Applying UIView animation
        let minimizeTransform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        animationView.transform = minimizeTransform
        UIView.animate(withDuration: 3.0, delay: 0.0, options: [.repeat, .autoreverse], animations: {
        animationView.transform = CGAffineTransform.identity
        }, completion: nil)
        
        view.addSubview(animationView)
        
        animationView.play()
    }
    
}
