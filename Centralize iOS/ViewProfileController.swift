//
//  ViewProfileController.swift
//  Centralize iOS
//
//  Created by Max Prudhomme on 05/04/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class ViewProfileController: UIViewController {

    @IBOutlet weak var tabBarBtn: UITabBarItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var searchBtn: UIBarButtonItem!
    @IBOutlet weak var menuBar: UINavigationItem!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var bioLbl: UITextView!
    
    var userInfosLoaded = false
    var profileInfosLoaded = false
    
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
        self.menuBar.title = t.valueForKey("YOUR_PROFILE")! as? String
        self.tabBarBtn.title = t.valueForKey("PROFILE")! as? String
        self.imageView.image = getImageLoader()
        self.bioLbl.hidden = true
        self.nameLbl.hidden = true
        self.locationLbl.hidden = true
        if self.revealViewController() != nil {
            menuBtn.target = self.revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.disableUI()
        
        let user_id = NSUserDefaults.standardUserDefaults().objectForKey("user_id") as! Int
        
        self.loadUserInfos(user_id)
    }
    
    func loadUserInfos(user_id: Int) {
        let session = APIGETSession("/users/\(user_id)/")
        
        let task = session[0].dataTaskWithRequest(session[1] as! NSURLRequest, completionHandler: {data, response, error -> Void in
            do {
                if data == nil {
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        simpleAlert((t.valueForKey("CEN_NO_DATA_RECEIVED")! as? String)!, message: (t.valueForKey("CEN_NO_DATA_RECEIVED_DESC")! as? String)!)
                        self.imageView.hidden = true
                        self.enableUI()
                    }
                    return
                }
                let jsonResult:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                let first_name = jsonResult["first_name"]! as? String
                let last_name = jsonResult["last_name"]! as? String
                let profile = jsonResult["profile"]! as? NSDictionary
                
                let tbc = self.tabBarController as! ProfileController
                tbc.first_name = first_name!
                tbc.last_name = last_name!
                
                let profile_id = profile!.valueForKey("id") as! Int
                tbc.profile_id = profile_id
                
                self.loadProfileInfos(profile_id)
            }
            catch {
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    simpleAlert((t.valueForKey("CEN_NOT_REACHABLE")! as? String)!, message: (t.valueForKey("CEN_NOT_REACHABLE_DESC")! as? String)!)
                }
                self.imageView.hidden = true
                self.enableUI()
            }
        })
        task.resume()
    }
    
    func loadProfileInfos(profile_id: Int) {
        let session = APIGETSession("/profile/\(profile_id)/")
        
        let task = session[0].dataTaskWithRequest(session[1] as! NSURLRequest, completionHandler: {data, response, error -> Void in
            do {
                if data == nil {
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        simpleAlert((t.valueForKey("CEN_NO_DATA_RECEIVED")! as? String)!, message: (t.valueForKey("CEN_NO_DATA_RECEIVED_DESC")! as? String)!)
                        self.imageView.hidden = true
                        self.enableUI()
                    }
                    return
                }
                let jsonResult:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                
                let city = jsonResult["city"]! as? String
                let country = jsonResult["country"]! as? String
                let bio = jsonResult["bio"]! as? String
                
                let tbc = self.tabBarController as! ProfileController
                tbc.city = city!
                tbc.country = country!
                tbc.biography = bio!
                
                self.displayInfos()
            }
            catch {
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    simpleAlert((t.valueForKey("CEN_NOT_REACHABLE")! as? String)!, message: (t.valueForKey("CEN_NOT_REACHABLE_DESC")! as? String)!)
                }
                self.imageView.hidden = true
                self.enableUI()
            }
        })
        task.resume()
    }
    
    func displayInfos() {
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            let tbc = self.tabBarController as! ProfileController
            
            self.nameLbl.text = tbc.first_name + " " + tbc.last_name
            self.locationLbl.text = tbc.city + ", " + tbc.country
            self.bioLbl.text = tbc.biography
            
            self.bioLbl.hidden = false
            self.nameLbl.hidden = false
            self.locationLbl.hidden = false
            self.imageView.hidden = true
            self.enableUI()
        }
    }
    
    func loadProfile_old() {
        self.disableUI()
        
        let session = APIGETSession("/users/profile/")
        
        let task = session[0].dataTaskWithRequest(session[1] as! NSURLRequest, completionHandler: {data, response, error -> Void in
            do {
                if data == nil {
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        simpleAlert((t.valueForKey("CEN_NO_DATA_RECEIVED")! as? String)!, message: (t.valueForKey("CEN_NO_DATA_RECEIVED_DESC")! as? String)!)
                        self.imageView.hidden = true
                        self.enableUI()
                    }
                    return
                }
                let jsonResult:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                self.displayProfile(jsonResult)
                self.enableUI()
            }
            catch {
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    simpleAlert((t.valueForKey("CEN_NOT_REACHABLE")! as? String)!, message: (t.valueForKey("CEN_NOT_REACHABLE_DESC")! as? String)!)
                }
                self.enableUI()
            }
        })
        task.resume()
    }
    
    func displayProfile(jsonResult: NSDictionary) {
        
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            let first_name = jsonResult["first_name"]! as? String
            let last_name = jsonResult["last_name"]! as? String
            let city = jsonResult["city"]! as? String
            let country = jsonResult["country"]! as? String
            let bio = jsonResult["bio"]! as? String
            self.nameLbl.text = first_name! + " " + last_name!
            self.locationLbl.text = city! + ", " + country!
            self.bioLbl.text = bio!
            
            // condition if user id == token TODO
            let tbc = self.tabBarController as! ProfileController
            tbc.first_name = first_name!
            tbc.last_name = last_name!
            tbc.city = city!
            tbc.country = country!
            tbc.biography = bio!
            
            self.bioLbl.hidden = false
            self.nameLbl.hidden = false
            self.locationLbl.hidden = false
            self.imageView.hidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
