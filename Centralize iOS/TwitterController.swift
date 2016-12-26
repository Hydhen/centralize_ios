//
//  TwitterController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 17/09/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class TwitterController: UIViewController, UITabBarDelegate {

    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
//    @IBOutlet weak var tabBar: UITabBar!
//    @IBOutlet weak var newTweetTab: UITabBarItem!
//    @IBOutlet weak var mentionsTab: UITabBarItem!
    
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

//    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
//        if (item.tag == 0) {
//            NSOperationQueue.mainQueue().addOperationWithBlock(){
//                let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
//                let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("twitterNewTweetController")
//                self.presentViewController(nextController, animated: true, completion: nil)
//            }
//        } else if (item.tag == 1) {
//            NSOperationQueue.mainQueue().addOperationWithBlock(){
//                let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
//                let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("twitterMentionsController")
//                self.presentViewController(nextController, animated: true, completion: nil)
//            }
//        }
//    }
    
    @IBAction func loadMore(sender: AnyObject) {
        let idx = self.tweets.count - 1
        let new = self.tweets[idx].valueForKey("id")!
        let token = String(new)

        self.disableUI()
        self.tableView.hidden = true
        self.errorLabel.hidden = true
        self.imageView.hidden = false

        let session = APIGETSession("/twitter/gettimeline/\(current_service)/?from_id=\(token)")
        
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
    
    
    func fetchTweets() {
        self.disableUI()
        self.tableView.hidden = true
        self.errorLabel.hidden = true
        self.imageView.hidden = false
        let session = APIGETSession("/twitter/gettimeline/\(current_service)/")
        
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

        self.navigationBar.title = "Twitter"// t.valueForKey("DRIVE")! as? String
        self.tableView.hidden = true
        self.errorLabel.text = "Error"// t.valueForKey("DRIVE_NO_FILE")! as? String
        self.errorLabel.hidden = true
        self.imageView.image = getImageLoader()
        self.imageView.hidden = true
    }
    override func viewDidAppear(animated: Bool) {
        self.fetchTweets()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("TweetListCell", forIndexPath: indexPath) as! TweetListCell
        cell.tweet.text = tweet.valueForKey("text") as? String
        let image = UIImage(data: data!)
        cell.userImg.image = image
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
