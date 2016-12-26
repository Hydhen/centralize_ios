//
//  GithubRepositoryController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 18/11/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

var current_github_repository: NSDictionary = [:]

class GithubRepositoryController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var noRepositoryLbl: UILabel!

    var repositories: NSMutableArray = []
    
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
        
        print ("SERVICE_ID: \(current_service)")
        let session: NSArray = APIGETSession("/github/listrepos/\(current_service)/")
        
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
                    self.repositories = jsonResult
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
        self.navigationBar.title = "Repositories" // TODO
        self.tableView.hidden = true
        self.imageView.image = getImageLoader()
        self.imageView.hidden = true
        self.noRepositoryLbl.text = "No repository found" // TODO
        self.noRepositoryLbl.hidden = true
        self.fetchRepositories()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.repositories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let repo = (self.repositories[indexPath.row] as? NSDictionary)!
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("githubRepositoryCell", forIndexPath: indexPath)
        cell.textLabel!.text = repo.valueForKey("name") as? String
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        print("repo selected: \(self.repositories[indexPath.row])")
        current_github_repository = self.repositories[indexPath.row] as! NSDictionary
        
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("githubRepositoryTab")
            self.presentViewController(nextController, animated: true, completion: nil)
        }
        return indexPath
    }
}
