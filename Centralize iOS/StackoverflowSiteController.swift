//
//  StackoverflowSiteController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 04/11/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class StackoverflowSiteController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noSiteLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    var results: NSMutableArray = []
    
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
    
    func fetchSites() -> Void {
        self.disableUI()
        self.tableView.hidden = true
        self.imageView.hidden = false
        self.noSiteLabel.hidden = true
        
        let session: NSArray = APIGETSession("/stackoverflow/sites/\(current_service)/")
        
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
                
                if jsonResult.valueForKey("items") == nil {
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        simpleAlert((t.valueForKey("CEN_NOT_REACHABLE")! as? String)!, message: (jsonResult.valueForKey("details")! as? String)!)
                        let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                        let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("homeController")
                        self.presentViewController(nextController, animated: true, completion: nil)
                        self.enableUI()
                    }
                } else {
                    self.results = jsonResult["items"] as! NSMutableArray
                    
                    if self.results.count == 0 {
                        NSOperationQueue.mainQueue().addOperationWithBlock() {
                            self.imageView.hidden = true
                            self.noSiteLabel.hidden = false
                            self.enableUI()
                        }
                    } else {
                        NSOperationQueue.mainQueue().addOperationWithBlock() {
                            self.tableView.reloadData()
                            self.tableView.hidden = false
                            self.imageView.hidden = true
                            self.enableUI()
                        }
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
        self.navigationBar.title = "Sites" // TODO
        self.tableView.hidden = true
        self.noSiteLabel.text = "No site found" // TODO
        self.noSiteLabel.hidden = true
        self.imageView.image = getImageLoader()
        self.imageView.hidden = true
        self.fetchSites()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let result = (self.results[indexPath.row] as? NSDictionary)!
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("stackoverflowSiteCell", forIndexPath: indexPath)
        cell.textLabel?.text = result.valueForKey("name") as? String
        
        let url = NSURL(string: result["icon_url"]! as! String)
        let data = NSData(contentsOfURL: url!)
        let image = UIImage(data: data!)
        cell.imageView?.image = image
        
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            UIApplication.sharedApplication().openURL(NSURL(string: self.results[indexPath.row].valueForKey("site_url") as! String)!)
        }
        return indexPath
    }
}
