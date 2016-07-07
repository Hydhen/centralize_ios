//
//  GmailReplyController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 02/07/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class GmailReplyController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!

    @IBAction func sendBtnAction(sender: AnyObject) {
        if self.textView == nil || self.textView == "" {
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                simpleAlert((t.valueForKey("REPLY_EMPTY")! as? String)!, message: (t.valueForKey("REPLY_EMPTY_DESC")! as? String)!)
            }
        } else {
            self.disableUI()
            self.imageView.hidden = false
            let allowed = NSMutableCharacterSet.alphanumericCharacterSet()
            var reply = textView.text!
            
            reply = reply.stringByAddingPercentEncodingWithAllowedCharacters(allowed)!

            var reply_content = "reply_content="
            reply_content += reply
            
            let url: String = "/gmail/replythread/\(current_service)/\(current_gmail_thread)/"
            
            let session = APIPOSTSession(url, data_string: reply_content)
            
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
                    
                    let _:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    self.enableUI()
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        let gmailMessageController = storyBoard.instantiateViewControllerWithIdentifier("gmailMessage") as! GmailMessageController
                        self.presentViewController(gmailMessageController, animated:true, completion:nil)
                    }

                }
                catch {
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        simpleAlert((t.valueForKey("CEN_NOT_REACHABLE")! as? String)!, message: (t.valueForKey("CEN_NOT_REACHABLE_DESC")! as? String)!)
                        self.imageView.hidden = true
                    }
                    self.enableUI()
                }
            })
            task.resume()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = getImageLoader()
        self.imageView.hidden = true
        self.textView.layer.borderColor = UIColor.init(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0).CGColor
        self.textView.layer.borderWidth = 1.0;
        self.textView.layer.cornerRadius = 5.0;
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
