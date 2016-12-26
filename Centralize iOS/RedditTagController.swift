//
//  RedditTagController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 25/12/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class RedditTagController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noTagLabel: UILabel!
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
    
    func fetchTags() -> Void {
        self.disableUI()
        self.tableView.hidden = true
        self.imageView.hidden = false
        self.noTagLabel.hidden = true
        
        let session: NSArray = APIGETSession("/reddit/subreddits/\(current_service)/")
        
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
                print("toto")
                let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                
                print (jsonResult)
                print("toto")
                
                if jsonResult.valueForKey("data") == nil {
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        simpleAlert((t.valueForKey("CEN_NOT_REACHABLE")! as? String)!, message: (jsonResult.valueForKey("details")! as? String)!)
                        let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                        let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("homeController")
                        self.presentViewController(nextController, animated: true, completion: nil)
                        self.enableUI()
                    }
                } else {
                    self.results = jsonResult.valueForKey("data")!.valueForKey("children") as! NSMutableArray
                    
                    if self.results.count == 0 {
                        NSOperationQueue.mainQueue().addOperationWithBlock() {
                            self.imageView.hidden = true
                            self.noTagLabel.hidden = false
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
        self.navigationBar.title = "Tags" // TODO
        self.tableView.hidden = true
        self.noTagLabel.text = "No tag found" // TODO
        self.noTagLabel.hidden = true
        self.imageView.image = getImageLoader()
        self.imageView.hidden = true
        self.fetchTags()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let result = (self.results[indexPath.row] as? NSDictionary)!
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("redditTagCell", forIndexPath: indexPath)
        cell.textLabel?.text = result["data"]!["display_name"]! as? String
        
        return cell
    }

    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
            let result = self.results[indexPath.row] as? NSDictionary
            let data = result?.valueForKey("data")!.valueForKey("display_name")! as! String
            current_reddit_search = data
            let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("redditService")
            self.presentViewController(nextController, animated: true, completion: nil)
        return indexPath
    }
}
