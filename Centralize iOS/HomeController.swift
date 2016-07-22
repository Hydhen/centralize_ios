//
//  ViewController.swift
//  Centralize iOS
//
//  Created by Max Prudhomme on 24/03/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

var t:NSDictionary = [:]

class HomeController: UIViewController {
    
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    @IBOutlet weak var imageView: UIImageView!
    
    func disableUI() {
        NSOperationQueue.mainQueue().addOperationWithBlock(){
            self.view.endEditing(true)
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        }
    }
    func enableUI() {
        NSOperationQueue.mainQueue().addOperationWithBlock(){
            if UIApplication.sharedApplication().isIgnoringInteractionEvents() {
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = getImageLoader()
        let i18n = I18n()
        t = i18n.load_locales()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.disableUI()
        
        //----------------------------------------------//
        //      DEBUG CES LIGNES DOIVENT DISPARAITRES   //
        //----------------------------------------------//
        
//        let username: String = "hydhen"
//        let token: NSDictionary = ["access_token": "Muu2uDTe867weXxqFPObInySkKsKrD"]
//        
//        NSUserDefaults.standardUserDefaults().setObject(username, forKey: "username")
//        NSUserDefaults.standardUserDefaults().setObject(token, forKey: "token_access")
        
        //----------------------------------------------//
        //      FIN DU DEBUG                            //
        //----------------------------------------------//

//        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "username")
//        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "token_access")

        // REMOVED TO TRY CONNEXION
        
        let hasUsername = NSUserDefaults.standardUserDefaults().objectForKey("username")
        
        if hasUsername == nil {
            NSOperationQueue.mainQueue().addOperationWithBlock(){
                self.enableUI()
                let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("loginController")
                self.presentViewController(nextController, animated: true, completion: nil)
            }
        } else {
//            let o = OAuthCtrl()
//            o.refresh_token { (success, title, message, data) -> Void in
                NSOperationQueue.mainQueue().addOperationWithBlock() {
//                    if (!success) {
//                        simpleAlert(title, message: message)
//                    }
                    self.enableUI()
                    self.imageView.hidden = true
                    self.loadMenu()
                }
//            }
        }
    }
    
    func loadMenu() {
        if self.revealViewController() != nil {
            menuBtn.target = self.revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
