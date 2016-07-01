//
//  ViewController.swift
//  Centralize iOS
//
//  Created by Max Prudhomme on 17/02/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class SignoutController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = getImageLoader()
    }
    
    override func viewDidAppear(animated: Bool) {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "username")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "token_access")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "user_id")
        NSOperationQueue.mainQueue().addOperationWithBlock(){
            let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("loginController")
            self.presentViewController(nextController, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
