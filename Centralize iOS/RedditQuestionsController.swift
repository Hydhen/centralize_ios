//
//  RedditQuestionsController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 23/12/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

var current_reddit_questions: NSMutableArray = []
var current_reddit_search: String = ""
var current_reddit_question: NSDictionary = [:]

class RedditQuestionsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var noResultLabel: UILabel!
    
    var results: NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.title = "Questions" // TODO
        self.tableView.hidden = true
        self.imageView.image = getImageLoader()
        self.imageView.hidden = true
        self.noResultLabel.text = "No result found" // TODO
        self.noResultLabel.hidden = true
        
        print ("------")
        print (current_reddit_search)
        print (self.searchBar.text)
        
        if current_reddit_search != "" && current_reddit_search != self.searchBar.text {
            print ("------")
            print("does not match")
            self.searchBar.text = current_reddit_search
            self.search("")
        }

        if current_reddit_questions.count > 0 {
            NSOperationQueue.mainQueue().addOperationWithBlock(){
                self.results = current_reddit_questions
                self.tableView.reloadData()
                self.tableView.hidden = false
                self.searchBar.text = current_reddit_search
            }
        }
    }
    
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
    
    @IBAction func search(sender: AnyObject) {
        self.disableUI()
        if self.searchBar.text == nil || self.searchBar.text == "" {
            simpleAlert("Ne peut etre vide", message: "Ne peut etre vide") // TODO
            self.enableUI()
        } else {
            self.tableView.hidden = true
            self.imageView.hidden = false
            self.noResultLabel.hidden = true
            
            let allowed = NSMutableCharacterSet.alphanumericCharacterSet()
            allowed.addCharactersInString("-")
            
            let search = self.searchBar.text!.stringByAddingPercentEncodingWithAllowedCharacters(allowed)!
            
            print ("/reddit/searchlinks/\(current_service)/?search=\(self.searchBar.text!)")
            let session: NSArray = APIGETSession("/reddit/searchlinks/\(current_service)/?search=\(search)")
            
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
                    
                    if jsonResult.valueForKey("data")?.valueForKey("children") == nil {
                        NSOperationQueue.mainQueue().addOperationWithBlock() {
                            simpleAlert((t.valueForKey("CEN_NOT_REACHABLE")! as? String)!, message: (jsonResult.valueForKey("details")! as? String)!)
                            let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                            let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("homeController")
                            self.presentViewController(nextController, animated: true, completion: nil)
                            self.enableUI()
                        }
                    } else {
                        self.results = jsonResult["data"]!["children"] as! NSMutableArray
                        
                        if self.results.count == 0 {
                            NSOperationQueue.mainQueue().addOperationWithBlock() {
                                self.imageView.hidden = true
                                self.noResultLabel.hidden = false
                                self.enableUI()
                            }
                        } else {
                            NSOperationQueue.mainQueue().addOperationWithBlock() {
                                self.tableView.reloadData()
                                self.tableView.hidden = false
                                self.imageView.hidden = true
                                current_reddit_questions = self.results
                                current_reddit_search = self.searchBar.text!
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
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let result = (self.results[indexPath.row] as? NSDictionary)!
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("redditQuestionCell", forIndexPath: indexPath)
        cell.textLabel?.text = result.valueForKey("data")!.valueForKey("title") as? String

        let details = result.valueForKey("data")!.valueForKey("subreddit") as? String
        cell.detailTextLabel?.text = details

        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            let question = (self.results[indexPath.row] as? NSDictionary)!
            current_reddit_question = question
            NSOperationQueue.mainQueue().addOperationWithBlock(){
                let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("redditQuestionDetails")
                self.presentViewController(nextController, animated: true, completion: nil)
            }
        }
        return indexPath
    }
}
