//
//  GmailThreadMessagesController.swift
//  Centralize iOS
//
//  Created by Max Prudhomme on 15/04/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

var current_gmail_message = ""

class GmailThreadMessagesController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBAction func archiveThread(sender: AnyObject) {
        self.disableUI()

        let session = APIGETSession("/gmail/archivethread/\(current_dashboard)/\(current_gmail_thread)/")
        
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
                let _ = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                
                let gmailThreadsController = storyBoard.instantiateViewControllerWithIdentifier("gmailService") as! GmailThreadsController
                
                self.presentViewController(gmailThreadsController, animated:true, completion:nil)
                
                self.enableUI()
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

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var menuBar: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    var gmail_threads_messages:NSMutableArray = []
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.hidden = true
        self.menuBar.title = t.valueForKey("MESSAGES")! as? String
        self.imageView.image = getImageLoader()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.loadThreads()
    }
    
    func loadThreads() {
        self.disableUI()
        
        let session = APIGETSession("/gmail/getthreadmessages/\(current_dashboard)/\(current_gmail_thread)/")
        
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
                
                self.gmail_threads_messages = (jsonResult.valueForKey("messages")! as? NSMutableArray)!
                
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    self.tableView.reloadData()
                    self.tableView.hidden = false
                    self.imageView.hidden = true
                    self.enableUI()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gmail_threads_messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let thread = (self.gmail_threads_messages[indexPath.row] as? NSDictionary)!
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        cell.textLabel?.text = (thread.valueForKey("snippet")! as? String)!
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let thread = (self.gmail_threads_messages[indexPath.row] as? NSDictionary)!
        current_gmail_message = (thread.valueForKey("id")! as? String)!
        NSOperationQueue.mainQueue().addOperationWithBlock(){
            let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("gmailMessage")
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
