//
//  FacebookGroupListController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 23/10/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class FacebookGroupListController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var noGroupsLbl: UILabel!
    
    var groups : NSMutableArray = []
    
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
    
    func fetchGroups() {
        self.disableUI()
        self.tableView.hidden = true
        self.noGroupsLbl.hidden = true
        self.imageView.hidden = false
        let session = APIGETSession("/facebook/groups/\(current_service)/")
        
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
                    self.groups = (jsonResult["data"]! as? NSMutableArray)!
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        if self.groups.count == 0 {
                            self.noGroupsLbl.hidden = false
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.title = "Facebook Groups"//TODO t.valueForKey("DRIVE")! as? String
        self.tableView.hidden = true
        self.noGroupsLbl.text = "No groups found"//TODO t.valueForKey("DRIVE_NO_FILE")! as? String
        self.noGroupsLbl.hidden = true
        self.noGroupsLbl.textAlignment = NSTextAlignment.Center
        self.imageView.image = getImageLoader()
        self.imageView.hidden = true
        self.fetchGroups()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groups.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let group = (self.groups[indexPath.row] as? NSDictionary)!
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("facebookGroupListCell", forIndexPath: indexPath)
        cell.textLabel!.text = group.valueForKey("name") as? String
        return cell
    }

}
