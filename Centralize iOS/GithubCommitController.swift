//
//  GithubCommitController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 25/11/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class GithubCommitController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var noCommitLbl: UILabel!
    
    var commits: NSMutableArray = []

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
    
    func fetchRepositories() {
        self.disableUI()
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            self.tableView.hidden = true
            self.imageView.hidden = false
        }
        
        let session: NSArray = APIGETSession("/github/getcommits/\(current_service)/?owner=\(current_github_repository.valueForKey("owner")?.valueForKey("login")! as! String)&repo=\(current_github_repository.valueForKey("name")! as! String)")
        
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
                    self.commits = jsonResult
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
        self.navigationBar.title = "Commits" // TODO
        self.tableView.hidden = true
        self.imageView.image = getImageLoader()
        self.imageView.hidden = true
        self.noCommitLbl.text = "No commit found" // TODO
        self.noCommitLbl.hidden = true
        self.fetchRepositories()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commits.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let commit = (self.commits[indexPath.row] as? NSDictionary)!
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("githubCommitCell", forIndexPath: indexPath) as! GithubCommitCell
        cell.message.text = commit.valueForKey("commit")!.valueForKey("message")! as? String
        cell.author.text = commit.valueForKey("commit")!.valueForKey("author")!.valueForKey("name")! as? String

        let date_string = commit.valueForKey("commit")!.valueForKey("author")!.valueForKey("date")! as? String
        let date = getHumanReadableDateFromString(date_string!)
        cell.date.text = date
        
        return cell
    }
    
//    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
//        print("repo selected: \(self.commits[indexPath.row])")
//        current_github_repository = self.commits[indexPath.row] as! NSDictionary
//        
//        NSOperationQueue.mainQueue().addOperationWithBlock() {
//            let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
//            let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("githubRepositoryTab")
//            self.presentViewController(nextController, animated: true, completion: nil)
//        }
//        return indexPath
//    }
}
