//
//  FacebookGroupController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 13/11/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class FacebookGroupController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var noStatusLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sendButton: UIButton!
    
    var posts : NSMutableArray = []
    
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
    
    func fetchPosts() {
        self.disableUI()
        self.tableView.hidden = true
        self.noStatusLbl.hidden = true
        self.imageView.hidden = false
        let session = APIGETSession("/facebook/groupfeed/\(current_service)/group/\(current_facebook_group["id"]!)")
        
        print ("REQUEST:: /facebook/groupfeed/\(current_service)/group/\(current_facebook_group["id"]!)")
        
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
                
                print ("JSONRESULT::\(jsonResult)")
                
                if jsonResult.valueForKey("data") == nil {
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        simpleAlert((t.valueForKey("CEN_NOT_REACHABLE")! as? String)!, message: (jsonResult.valueForKey("detail")! as? String)!)
                        let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                        let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("homeController")
                        self.presentViewController(nextController, animated: true, completion: nil)
                        self.enableUI()
                    }
                } else {
                    self.posts = (jsonResult["data"]! as? NSMutableArray)!
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        if self.posts.count == 0 {
                            self.noStatusLbl.hidden = false
                        } else {
                            self.tableView.reloadData()
                            self.tableView.hidden = false
                        }
                        self.imageView.hidden = true
                        self.enableUI()
                    }
                }
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

    @IBAction func sendButtonPressed(sender: AnyObject) {
        let allowed = NSMutableCharacterSet.alphanumericCharacterSet()
        allowed.addCharactersInString("-")
        
        var stringPost: String = "message="
        stringPost += self.textField.text!
        
        if (self.textField.text != nil && self.textField.text != "") {
            let session = APIPOSTSession("/facebook/groupfeedpost/\(current_service)/group/\(current_facebook_group["id"]!)", data_string: stringPost)
            
            print(current_service)
            print(stringPost)
            
            let task = session[0].dataTaskWithRequest(session[1] as! NSURLRequest, completionHandler: {data, response, error -> Void in
                do {
                    if data == nil {
                        NSOperationQueue.mainQueue().addOperationWithBlock() {
                            simpleAlert((t.valueForKey("CEN_NO_DATA_RECEIVED")! as? String)!, message: (t.valueForKey("CEN_NO_DATA_RECEIVED_DESC")! as? String)!)
                        }
                        return
                    }
                    let jsonResult:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    print (jsonResult)
                }
                catch {
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        simpleAlert((t.valueForKey("CEN_NOT_REACHABLE")! as? String)!, message: (t.valueForKey("CEN_NOT_REACHABLE_DESC")! as? String)!)
                    }
                }
            })
            task.resume()
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                simpleAlert("Status envoyé", message: "Votre status a été mis à jour") //TODO
            }
        } else {
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                simpleAlert("Status vide", message: "Ne peux envoyer un status vide") //TODO
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.title = "Facebook Groups"//TODO t.valueForKey("DRIVE")! as? String
        self.tableView.hidden = true
        self.noStatusLbl.text = "No groups found"//TODO t.valueForKey("DRIVE_NO_FILE")! as? String
        self.noStatusLbl.hidden = true
        self.noStatusLbl.textAlignment = NSTextAlignment.Center
        self.imageView.image = getImageLoader()
        self.imageView.hidden = true
        self.fetchPosts()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let post = (self.posts[indexPath.row] as? NSDictionary)!
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("facebookGroupListCell", forIndexPath: indexPath)
        cell.textLabel!.text = post.valueForKey("name") as? String
        return cell
    }
//    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
//        current_facebook_group = self.groups[indexPath.row] as! NSDictionary
//        
//        NSOperationQueue.mainQueue().addOperationWithBlock() {
//            let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
//            let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("facebookGroup") as! FacebookGroupController
//            self.presentViewController(nextController, animated: true, completion: nil)
//        }
//        return indexPath
//    }
}
