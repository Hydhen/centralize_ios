//
//  StackoverflowAnswerController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 04/11/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

var current_stackoverflow_answer: NSDictionary = [:]

class StackoverflowAnswerController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var noAnswerLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!

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
    
    func fetchAnswers() -> Void {
        self.disableUI()
        self.tableView.hidden = true
        self.imageView.hidden = false
        self.noAnswerLabel.hidden = true
        
        let session: NSArray = APIGETSession("/stackoverflow/getlistanswersforquestion/\(current_service)/?question=\(String(current_stackoverflow_question["question_id"]!))")
        
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
                
                print ("-------")
                print (jsonResult)
                
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
                            self.noAnswerLabel.hidden = false
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
        self.navigationBar.title = "Answers" // TODO
        self.noAnswerLabel.text = "No answer found" // TODO
        self.noAnswerLabel.hidden = true
        self.imageView.image = getImageLoader()
        self.imageView.hidden = true
        self.tableView.hidden = true
        self.fetchAnswers()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let result = (self.results[indexPath.row] as? NSDictionary)!
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("stackoverflowAnswerCell", forIndexPath: indexPath) as! StackoverflowAnswerCell
        cell.userName.text = result["owner"]!["display_name"]! as? String
        
        let url = NSURL(string: result["owner"]!["profile_image"]! as! String)
        let data = NSData(contentsOfURL: url!)
        let image = UIImage(data: data!)
        cell.userImage.image = image
        
        cell.webView.loadHTMLString(result["body"]! as! String, baseURL: nil)
        
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        current_stackoverflow_answer = self.results[indexPath.row] as! NSDictionary
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("stackoverflowComment")
            self.presentViewController(nextController, animated: true, completion: nil)
        }
        return indexPath
    }
}
