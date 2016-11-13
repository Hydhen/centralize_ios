 //
//  SlackChannelMessagesController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 21/10/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

var slack_current_message: UITextField!

class SlackChannelMessagesController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!

    var messages: NSMutableArray = []

    @IBAction func detectSpecials(sender: AnyObject) {
        let text = self.textField.text
        
        if text?.characters.last == "@"{
            let popUpUser = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("slackUserPopUp") as! SlackUserPopUpController
            self.addChildViewController(popUpUser)
            popUpUser.view.frame = self.view.frame
            self.view.addSubview(popUpUser.view)
            popUpUser.didMoveToParentViewController(self)
            print ("PopUp ended")
        } else if text?.characters.last == "#" {
            let popUpUser = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("slackChannelPopUp") as! SlackChannelPopUpController
            self.addChildViewController(popUpUser)
            popUpUser.view.frame = self.view.frame
            self.view.addSubview(popUpUser.view)
            popUpUser.didMoveToParentViewController(self)
            print ("PopUp ended")
        } else {
            print ("other")
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
    
    func fetchChannelMessages() -> Void {
        self.disableUI()
        self.tableView.hidden = true
        self.imageView.hidden = false
        
        let session: NSArray = APIGETSession("/slack/channel/\(current_service)/channel/\(current_channel.valueForKey("id")! as! String)/")
        
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

                self.messages = (jsonResult.valueForKey("messages")! as? NSMutableArray)!
                
                if self.messages.count < 1 {
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        simpleAlert((t.valueForKey("CEN_NOT_REACHABLE")! as? String)!, message: (jsonResult.valueForKey("details")! as? String)!)
                        let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                        let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("homeController")
                        self.presentViewController(nextController, animated: true, completion: nil)
                        self.enableUI()
                    }
                } else {
//                    self.channels = jsonResult["channels"] as! NSMutableArray
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
        self.navigationBar.title = current_channel.valueForKey("name")! as? String
        self.imageView.image = getImageLoader()
        self.fetchChannelMessages()
        slack_current_message = self.textField
    }
    
    @IBAction func sendMessage(sender: AnyObject) {
        if self.textField.text == nil || self.textField.text == "" {
            simpleAlert((t.valueForKey("SLACK_EMPTY_MESSAGE_SHORT")! as? String)!, message: (t.valueForKey("SLACK_EMPTY_MESSAGE_LONG")! as? String)!)
        } else {
            let stringPost: String = "message=\(self.textField.text)"
            print("stringPost: \(stringPost)")
            let session = APIPOSTSession("/slack/postmessage/\(current_service)/channel/\(current_channel.valueForKey("id")! as! String)/", data_string: stringPost)
            
            let task = session[0].dataTaskWithRequest(session[1] as! NSURLRequest, completionHandler: {data, response, error -> Void in
                do {
                    if data == nil {
                        NSOperationQueue.mainQueue().addOperationWithBlock() {
                            simpleAlert((t.valueForKey("CEN_NO_DATA_RECEIVED")! as? String)!, message: (t.valueForKey("CEN_NO_DATA_RECEIVED_DESC")! as? String)!)
                        }
                        return
                    }
                    
                    let jsonResult:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    print (jsonResult)
                }
                catch {
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        simpleAlert((t.valueForKey("CEN_NOT_REACHABLE")! as? String)!, message: (t.valueForKey("CEN_NOT_REACHABLE_DESC")! as? String)!)
                    }
                }
            })
            task.resume()
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.textField.text = ""
                sleep(1)
                self.fetchChannelMessages()
            }
        }
    }
    
    func getUserNameFromUserObject(message: NSDictionary) -> String {
        let id = message.valueForKey("user")! as! String
        
        for u in current_slack_users {
            let userId = u.valueForKey("id")
            if userId == nil {
                return "Unnamed" // TODO
            } else if userId! as! String == id {
                return u.valueForKey("name")! as! String
            }
        }
        return "Unnamed" // TODO
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let message = (self.messages[indexPath.row] as? NSDictionary)!
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("slackMessageCell", forIndexPath: indexPath) as! SlackMessageCell
        cell.message.text = message.valueForKey("text") as? String
        let userName = getUserNameFromUserObject(message)
        cell.author.text = userName
        return cell
    }
}
