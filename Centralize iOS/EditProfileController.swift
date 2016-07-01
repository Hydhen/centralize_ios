//
//  EditProfileController.swift
//  Centralize iOS
//
//  Created by Max Prudhomme on 08/04/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class EditProfileController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var menuBar: UINavigationItem!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var tabBarBtn: UITabBarItem!

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var firstnameLbl: UILabel!
    @IBOutlet weak var lastnameLbl: UILabel!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var countryLbl: UILabel!
    @IBOutlet weak var biographyLbl: UILabel!
    
    @IBOutlet weak var firstnameField: UITextField!
    @IBOutlet weak var lastnameField: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var countryField: UITextField!
    @IBOutlet weak var biographyField: UITextView!
    
    @IBOutlet weak var btnSave: UIButton!
    
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
    
    @IBAction func saveProfile(sender: AnyObject) {
        self.scrollView.endEditing(true)
        self.disableUI()
        self.imageView.hidden = false
        self.saveUserInfos()
    }
    
    func saveUserInfos() {
        if self.firstnameField.text! != "" {
            let first_name = self.firstnameField.text!
            if self.lastnameField.text != "" {
                let last_name = self.lastnameField.text!
                let tbc = self.tabBarController as! ProfileController
                if first_name != tbc.first_name || last_name != tbc.last_name {
                    let user_id = NSUserDefaults.standardUserDefaults().objectForKey("user_id") as! Int
                    let stringPost = "first_name=" + first_name
                        + "&last_name=" + last_name
                    let session = APIPATCHSession("/users/\(user_id)/", data_string: stringPost)
                    
                    let task = session[0].dataTaskWithRequest(session[1] as! NSURLRequest, completionHandler: {data, response, error -> Void in
                        
                    })
                    task.resume()
                }
                self.saveProfileInfos()
            } else {
                simpleAlert((t.valueForKey("LASTNAME_MISSING")! as? String)!, message: (t.valueForKey("LASTNAME_MISSING_DESC")! as? String)!)
                self.enableUI()
                self.imageView.hidden = true
            }
        } else {
            simpleAlert((t.valueForKey("FIRSTNAME_MISSING")! as? String)!, message: (t.valueForKey("FIRSTNAME_MISSING_DESC")! as? String)!)
            self.enableUI()
            self.imageView.hidden = true
        }
    }
    
    func saveProfileInfos() {
        let tbc = self.tabBarController as! ProfileController
        let stringPost = "city=" + self.cityField.text! + "&country=" + self.countryField.text! + "&bio=" + self.biographyField.text!
        let profile_id = tbc.profile_id
        
        let session = APIPATCHSession("/profile/\(profile_id)/", data_string: stringPost)
        
        let task = session[0].dataTaskWithRequest(session[1] as! NSURLRequest, completionHandler: {data, response, error -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    if httpResponse.statusCode == 200 {
                        simpleAlert((t.valueForKey("PROFILE_SAVED")! as? String)!, message: (t.valueForKey("PROFILE_SAVED_DESC")! as? String)!)
                    } else {
                        simpleAlert((t.valueForKey("ERROR")! as? String)!, message: (t.valueForKey("ERROR_DESC")! as? String)!)
                    }
                    self.enableUI()
                    self.imageView.hidden = true
                }
            }
        })
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = getImageLoader()
        self.imageView.hidden = true
        if self.revealViewController() != nil {
            menuBtn.target = self.revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.firstnameField.delegate = self
        self.lastnameField.delegate = self
        self.cityField.delegate = self
        self.countryField.delegate = self
        self.biographyField.delegate = self
        
        self.menuBar.title = (t.valueForKey("EDIT_YOUR_PROFILE")! as? String)!
        self.tabBarBtn.title = (t.valueForKey("EDIT_YOUR_PROFILE")! as? String)!
        self.btnSave.setTitle((t.valueForKey("SAVE")! as? String)!, forState: .Normal)

        self.firstnameLbl.text = (t.valueForKey("FIRST_NAME")! as? String)!
        self.lastnameLbl.text = (t.valueForKey("LAST_NAME")! as? String)!
        self.cityLbl.text = (t.valueForKey("CITY")! as? String)!
        self.countryLbl.text = (t.valueForKey("COUNTRY")! as? String)!
        self.biographyLbl.text = (t.valueForKey("BIOGRAPHY")! as? String)!
        
        let tbc = self.tabBarController as! ProfileController
        self.firstnameField.text = tbc.first_name
        self.lastnameField.text = tbc.last_name
        self.cityField.text = tbc.city
        self.countryField.text = tbc.country
        self.biographyField.text = tbc.biography
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardNotifications()
    }
    
    func registerKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unregisterKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardDidShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo!
        let keyboardSize = userInfo.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue.size
        let contentInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.scrollView.contentInset = UIEdgeInsetsZero
        self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.scrollView.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == self.firstnameField {
            self.lastnameField.becomeFirstResponder()
        } else if textField == self.lastnameField {
            self.cityField.becomeFirstResponder()
        } else if textField == self.cityField {
            self.countryField.becomeFirstResponder()
        } else if textField == self.countryField {
            self.biographyField.becomeFirstResponder()
        }
        return true
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
