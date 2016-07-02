//
//  GmailSearchController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 01/07/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class GmailSearchController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var threadLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuBar: UINavigationItem!
    @IBOutlet weak var loadMore: UIBarButtonItem!

    var searchThreads: NSMutableArray = []
    var nextPageToken: String? = nil
    var search: String = ""
    
    @IBAction func searchBtn(sender: AnyObject) {
        if searchField.text == "" {
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                simpleAlert((t.valueForKey("SEARCH_EMPTY")! as? String)!, message: (t.valueForKey("SEARCH_EMPTY_DESC")! as? String)!)
            }
        } else {
            self.disableUI()
            self.threadLabel.hidden = true
            self.tableView.hidden = true
            self.imageView.hidden = false
            var url: String = "/gmail/getthreads/\(current_dashboard)/?search="

            let allowed = NSMutableCharacterSet.alphanumericCharacterSet()
            var search = searchField.text!
                
            search = search.stringByAddingPercentEncodingWithAllowedCharacters(allowed)!
            url += search
            
            let session = APIGETSession(url)
            
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
                    
                    let nbThreads = (jsonResult.valueForKey("resultSizeEstimate")! as? Int)!
                    
                    if nbThreads > 0 {
                        self.searchThreads = (jsonResult.valueForKey("threads")! as? NSMutableArray)!
                        self.nextPageToken = jsonResult.valueForKey("nextPageToken") as? String
                        NSOperationQueue.mainQueue().addOperationWithBlock() {
                            self.tableView.reloadData()
                            self.tableView.hidden = false
                            self.imageView.hidden = true
                            self.loadMore.enabled = true
                            self.enableUI()
                        }
                    } else if nbThreads == 0 {
                        NSOperationQueue.mainQueue().addOperationWithBlock() {
                            self.loadMore.enabled = false
                            self.threadLabel.text = (t.valueForKey("SEARCH_NOT_FOUND") as! String)
                            self.threadLabel.hidden = false
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
    }
    @IBAction func loadMoreBtn(sender: AnyObject) {
        if nextPageToken == nil || nextPageToken! == "" {
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                simpleAlert((t.valueForKey("SEARCH_NO_MORE")! as? String)!, message: (t.valueForKey("SEARCH_NO_MORE_DESC")! as? String)!)
                self.loadMore.enabled = false
                self.enableUI()
            }
        } else {
            self.disableUI()
            self.threadLabel.hidden = true
            self.tableView.hidden = true
            self.imageView.hidden = false
            var url: String = "/gmail/getthreads/\(current_dashboard)/?search="
            
            let allowed = NSMutableCharacterSet.alphanumericCharacterSet()
            var search = searchField.text!
            
            search = search.stringByAddingPercentEncodingWithAllowedCharacters(allowed)!
            url += search
            url += "&next="
            url += nextPageToken!
            
            print(url)
            
            let session = APIGETSession(url)
            
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
                    
                    let nbThreads = (jsonResult.valueForKey("resultSizeEstimate")! as? Int)!
                    
                    if nbThreads > 0 {
                        let newThreads = (jsonResult.valueForKey("threads")! as? NSMutableArray)!
                        
                        for thread in newThreads {
                            self.searchThreads.addObject(thread)
                        }

                        print (self.searchThreads)
                        self.nextPageToken = jsonResult.valueForKey("nextPageToken") as? String
                        NSOperationQueue.mainQueue().addOperationWithBlock() {
                            self.tableView.reloadData()
                            self.tableView.hidden = false
                            self.imageView.hidden = true
                            self.loadMore.enabled = true
                            self.enableUI()
                        }
                    } else if nbThreads == 0 {
                        NSOperationQueue.mainQueue().addOperationWithBlock() {
                            simpleAlert((t.valueForKey("SEARCH_NO_MORE")! as? String)!, message: (t.valueForKey("SEARCH_NO_MORE_DESC")! as? String)!)
                            self.loadMore.enabled = false
                            self.threadLabel.text = (t.valueForKey("SEARCH_NOT_FOUND") as! String)
                            self.threadLabel.hidden = false
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
    }

    func disableUI() {
        NSOperationQueue.mainQueue().addOperationWithBlock(){
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadMore.enabled = false
        self.tableView.hidden = true
        self.menuBar.title = t.valueForKey("THREADS")! as? String
        self.threadLabel.text = t.valueForKey("SEARCH_KEYWORD")! as? String
        self.imageView.image = getImageLoader()
        self.imageView.hidden = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchThreads.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let thread = (self.searchThreads[indexPath.row] as? NSDictionary)!
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        cell.textLabel?.text = (thread.valueForKey("snippet")! as? String)!
        return cell
    }
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let thread = (self.searchThreads[indexPath.row] as? NSDictionary)!
        current_gmail_thread = (thread.valueForKey("id")! as? String)!
        NSOperationQueue.mainQueue().addOperationWithBlock(){
            let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("gmailThreadMessages")
            self.presentViewController(nextController, animated: true, completion: nil)
        }
        return indexPath
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
