//
//  ViewController.swift
//  Centralize iOS
//
//  Created by Max Prudhomme on 24/03/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class LoginController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    
    func resetStorageSession() {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "username")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "token_access")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "user_id")
    }
    
    func disableUI() {
        NSOperationQueue.mainQueue().addOperationWithBlock(){
            self.view.endEditing(true)
            self.loginBtn.hidden = true
            self.imageView.hidden = false
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        }
    }
    func enableUI() {
        NSOperationQueue.mainQueue().addOperationWithBlock(){
            self.loginBtn.hidden = false
            self.imageView.hidden = true
            if UIApplication.sharedApplication().isIgnoringInteractionEvents() {
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            }
        }
    }
    
    @IBAction func loginAction(sender: AnyObject) {
        
        disableUI()
        
        if usernameField.text! != "" {
            let username = usernameField.text!
            if passwordField.text != "" {
                let password = passwordField.text!
                signin(username, password: password)
            } else {
                simpleAlert((t.valueForKey("PASSWORD_MISSING")! as? String)!, message: (t.valueForKey("PASSWORD_MISSING_DESC")! as? String)!)
                enableUI()
            }
        } else {
            simpleAlert((t.valueForKey("USERNAME_MISSING")! as? String)!, message: (t.valueForKey("USERNAME_MISSING_DESC")! as? String)!)
            enableUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = getImageLoader()
        self.imageView.hidden = true
        self.passwordField.delegate = self
        self.usernameField.delegate = self
        self.usernameField.placeholder = (t.valueForKey("USERNAME")! as? String)!
        self.passwordField.placeholder = (t.valueForKey("PASSWORD")! as? String)!
    }
    
    func signin (username: String, password: String) {
        let o = OAuthCtrl()
        let url = NSURL(string: APIConstants.url + "/o/token/")
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "POST"
        let stringPost = "grant_type=password"
            + "&username=" + username
            + "&password=" + password
            + "&client_id=" + o.client_id
            + "&client_secret=" + o.client_secret
        
        print(stringPost)
        
        let data = stringPost.dataUsingEncoding(NSUTF8StringEncoding)
        request.timeoutInterval = 30
        request.HTTPBody = data
        request.HTTPShouldHandleCookies = false
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            do {
                if data == nil {
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        simpleAlert((t.valueForKey("CEN_NO_DATA_RECEIVED")! as? String)!, message: (t.valueForKey("CEN_NO_DATA_RECEIVED_DESC")! as? String)!)
                        self.enableUI()
                    }
                    return
                }
                let jsonResult:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                print(jsonResult)
                print(jsonResult["error"])

                if jsonResult["error"] != nil {
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        if jsonResult["error"]! as! String == "invalid_grant" {
                            simpleAlert((t.valueForKey("ACCOUNT_UNKNOWN")! as? String)!, message: (t.valueForKey("ACCOUNT_UNKNOWN_DESC")! as? String)!)
                        } else {
                            simpleAlert((t.valueForKey("CONNECTION_ERROR")! as? String)!, message: (t.valueForKey("CONNECTION_ERROR_DESC")! as? String)!)
                        }
                        self.enableUI()
                    }
                } else {
                    self.getUserId(username, token_access: jsonResult)
                }
            }
            catch {
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    simpleAlert((t.valueForKey("CEN_NOT_REACHABLE")! as? String)!, message: (t.valueForKey("CEN_NOT_REACHABLE_DESC")! as? String)!)
                    self.enableUI()
                }
            }
        })
        task.resume()
    }
    
    func getUserId(username: String, token_access: NSDictionary) {
        NSUserDefaults.standardUserDefaults().setObject(username, forKey: "username")
        NSUserDefaults.standardUserDefaults().setObject(token_access, forKey: "token_access")
        
        let session = APIGETSession("/utils/whoami/")
        
        let task = session[0].dataTaskWithRequest(session[1] as! NSURLRequest, completionHandler: {data, response, error -> Void in
            do {
                if data == nil {
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        self.resetStorageSession()
                        simpleAlert((t.valueForKey("CEN_NO_DATA_RECEIVED")! as? String)!, message: (t.valueForKey("CEN_NO_DATA_RECEIVED_DESC")! as? String)!)
                        self.imageView.hidden = true
                        self.enableUI()
                    }
                    return
                }
                let jsonResult:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                NSUserDefaults.standardUserDefaults().setObject(jsonResult["id"], forKey: "user_id")
                
                NSOperationQueue.mainQueue().addOperationWithBlock(){
                    self.enableUI()
                    self.performSegueWithIdentifier("toHome", sender: self)
                }
            }
            catch {
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    self.resetStorageSession()
                    simpleAlert((t.valueForKey("CEN_NOT_REACHABLE")! as? String)!, message: (t.valueForKey("CEN_NOT_REACHABLE_DESC")! as? String)!)
                }
                self.enableUI()
            }
        })
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == usernameField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            loginAction(self)
        }
        return true
    }
    
}
