//
//  TwitterMentionsController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 30/09/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class TwitterMentionsController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var tweets : NSMutableArray = []
    
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
    
    @IBAction func loadMore(sender: AnyObject) {
        let idx = self.tweets.count - 1
        let new = self.tweets[idx].valueForKey("id")!
        let token = String(new)
        
        
        print (idx)
        print (new)
        print (token)
        print ("/twitter/getmentions/\(current_service)/?from_id=\(token)")
        
        self.disableUI()
        self.tableView.hidden = true
        self.errorLabel.hidden = true
        self.imageView.hidden = false
        
        let session = APIGETSession("/twitter/getmentions/\(current_service)/?from_id=\(token)")
        
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
                
                let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSMutableArray
                let errorMessage = jsonResult.valueForKey("details") as? String
                
                if jsonResult.count == 1 && errorMessage != nil {
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        simpleAlert((t.valueForKey("CEN_NOT_REACHABLE")! as? String)!, message: (jsonResult.valueForKey("details") as? String)!)
                        let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                        let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("homeController")
                        self.presentViewController(nextController, animated: true, completion: nil)
                        self.enableUI()
                    }
                } else {
                    print (jsonResult)
                    jsonResult.removeObjectAtIndex(0)
                    for tweet in jsonResult {
                        self.tweets.addObject(tweet)
                    }
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
    

    func fetchMentions() {
        self.disableUI()
        self.tableView.hidden = true
        self.errorLabel.hidden = true
        self.imageView.hidden = false
        let session = APIGETSession("/twitter/getmentions/\(current_service)/")
        
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
                
                let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSMutableArray
                
                if jsonResult.count == 1 {
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        simpleAlert((t.valueForKey("CEN_NOT_REACHABLE")! as? String)!, message: (jsonResult.valueForKey("details") as? String)!)
                        let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                        let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("homeController")
                        self.presentViewController(nextController, animated: true, completion: nil)
                        self.enableUI()
                    }
                } else {
                    self.tweets = jsonResult
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

        self.navigationBar.title = "Mentions"
        self.tableView.hidden = true
        self.errorLabel.text = "Error"
        self.errorLabel.hidden = true
        self.imageView.image = getImageLoader()
        self.imageView.hidden = true
    }
    override func viewDidAppear(animated: Bool) {
        self.fetchMentions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tweet = (self.tweets[indexPath.row] as? NSDictionary)!
        
        print ("--- tweet")
        print (tweet)
        print ("tweet ---")
        
        let url = NSURL(string: tweet["user"]!["profile_image_url_https"]! as! String)
        let data = NSData(contentsOfURL: url!)
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("MentionListCell", forIndexPath: indexPath) as! MentionListCell
        cell.tweet.text = tweet.valueForKey("text") as? String
        let image = UIImage(data: data!)
        cell.userImg.image = image
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
