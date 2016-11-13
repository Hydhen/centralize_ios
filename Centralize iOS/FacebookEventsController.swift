//
//  FacebookEventsController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 23/10/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

var current_facebook_event: NSDictionary = [:]

class FacebookEventsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var segments: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var noEventLbl: UILabel!

    var eventType = ""
    
    var events : NSMutableArray = []
    
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
    
    func fetchEvents() {
        self.disableUI()
        self.tableView.hidden = true
        self.noEventLbl.hidden = true
        self.imageView.hidden = false
        let session = APIGETSession("/facebook/events/\(current_service)/" + (self.eventType != "" ? "?type=" + self.eventType : ""))
        
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
                
                if jsonResult.valueForKey("data") == nil {
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        simpleAlert((t.valueForKey("CEN_NOT_REACHABLE")! as? String)!, message: (jsonResult.valueForKey("details")! as? String)!)
                        let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                        let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("homeController")
                        self.presentViewController(nextController, animated: true, completion: nil)
                        self.enableUI()
                    }
                } else {
                    self.events = (jsonResult["data"]! as? NSMutableArray)!
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        if self.events.count == 0 {
                            self.noEventLbl.hidden = false
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
    
    @IBAction func segmentsOnClick(sender: AnyObject) {
        switch self.segments.selectedSegmentIndex {
        case 0:
            self.eventType = "not_replied"
        case 1:
            self.eventType = "attending"
        case 2:
            self.eventType = "maybe"
        case 3:
            self.eventType = "declined"
        default:
            self.eventType = "not_replied"
        }
        self.fetchEvents()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.title = "Facebook"//TODO t.valueForKey("DRIVE")! as? String
        self.tableView.hidden = true
        self.noEventLbl.text = "No event found"//TODO t.valueForKey("DRIVE_NO_FILE")! as? String
        self.noEventLbl.hidden = true
        self.noEventLbl.textAlignment = NSTextAlignment.Center
        self.imageView.image = getImageLoader()
        self.imageView.hidden = true
        self.segments.selectedSegmentIndex = 0
        self.fetchEvents()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let event = (self.events[indexPath.row] as? NSDictionary)!
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("facebookEventListCell", forIndexPath: indexPath)
        cell.textLabel!.text = event.valueForKey("name") as? String
        return cell
    }
//    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
//        let file = (self.files[indexPath.row] as? NSDictionary)!
//        
//        print ("--- file selected")
//        print (file)
//        print ("file selected ---")
//        
//        let file_type = file.valueForKey("mimeType") as! String
//        
//        if (file_type == "application/vnd.google-apps.folder") {
//            let child_id = file.valueForKey("id") as! String
//            let child_name = file.valueForKey("name") as! String
//            
//            self.history.append((child_id, child_name))
//            
//            print ("--- history")
//            print (history)
//            print ("history ---")
//            
//            NSOperationQueue.mainQueue().addOperationWithBlock(){
//                self.parentFolderButton.hidden = false
//                self.currentFolder.text = child_name
//                self.fetchFiles(child_id)
//            }
//        } else {
//            current_file = file
//            
//            NSOperationQueue.mainQueue().addOperationWithBlock(){
//                let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
//                let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("driveFile")
//                self.presentViewController(nextController, animated: true, completion: nil)
//            }
//        }
//        
//        return indexPath
//    }

}
