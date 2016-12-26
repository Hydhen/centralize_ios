//
//  GithubPullRequestController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 25/11/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class GithubPullRequestController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var noPullRequestLbl: UILabel!

    @IBAction func segmentChanged(sender: AnyObject) {
        self.fetchPullRequest()
    }
    
    var pullRequests: NSMutableArray = []
    
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
    
    func fetchPullRequest() {
        self.disableUI()
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            self.tableView.hidden = true
            self.imageView.hidden = false
        }
        
        var tag: String = ""
        
        if self.segment.selectedSegmentIndex == 0 {
            tag = "open"
        } else {
            tag = "closed"
        }
        
        print ("SERVICE_ID: \(current_service)")
        print ("REQUEST: \("/github/getpullrequests/\(current_service)/?owner=\(current_github_repository.valueForKey("owner")?.valueForKey("login")! as! String)&repo=\(current_github_repository.valueForKey("name")! as! String)&status=\(tag)")")
        let session: NSArray = APIGETSession("/github/getpullrequests/\(current_service)/?owner=\(current_github_repository.valueForKey("owner")?.valueForKey("login")! as! String)&repo=\(current_github_repository.valueForKey("name")! as! String)&status=\(tag)")
        
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
                
                let jsonResult:NSMutableArray = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSMutableArray
                
                if jsonResult.count <= 0 {
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        simpleAlert((t.valueForKey("CEN_NOT_REACHABLE")! as? String)!, message: "No data retrieved" /* TODO */)
                        let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                        let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("homeController")
                        self.presentViewController(nextController, animated: true, completion: nil)
                        self.enableUI()
                    }
                } else {
                    self.pullRequests = jsonResult
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        self.tableView.reloadData()
                        self.tableView.hidden = false
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
        self.navigationBar.title = "Pull Requests" // TODO
        self.tableView.hidden = true
        self.imageView.image = getImageLoader()
        self.imageView.hidden = true
        self.noPullRequestLbl.text = "No pull requests found" // TODO
        self.noPullRequestLbl.hidden = true
        self.fetchPullRequest()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pullRequests.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let pullRequest = (self.pullRequests[indexPath.row] as? NSDictionary)!
        print (pullRequest)
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("githubPullRequestCell", forIndexPath: indexPath)
        cell.textLabel!.text = pullRequest.valueForKey("head")!.valueForKey("ref")! as? String
        return cell
    }
    
//    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
//        print("pullRequest selected: \(self.pullRequests[indexPath.row])")
//        
//        NSOperationQueue.mainQueue().addOperationWithBlock() {
//            let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
//            let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("githubRepositoryTab")
//            self.presentViewController(nextController, animated: true, completion: nil)
//        }
//        return indexPath
//    }
}
