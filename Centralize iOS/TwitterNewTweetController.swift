//
//  TwitterNewTweetController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 19/09/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class TwitterNewTweetController: UIViewController, UITextFieldDelegate, UITabBarDelegate {

    @IBOutlet weak var tweetField: UITextField!
    @IBOutlet weak var counterLabel: UILabel!
    
    @IBAction func sendTweet(sender: AnyObject) {
        //    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        //        if (item.tag == 0) {
        print (tweetField.text)
        let allowed = NSMutableCharacterSet.alphanumericCharacterSet()
        allowed.addCharactersInString("-")
        
        var stringPost: String = "text="
        stringPost += tweetField.text!
        //            stringPost = stringPost.stringByAddingPercentEncodingWithAllowedCharacters(allowed)!
        
        if (tweetField.text != nil && tweetField.text != "") {
            let session = APIPOSTSession("/twitter/tweet/\(current_service)/", data_string: stringPost)
            
            print(current_service)
            print(stringPost)
            
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
            
            NSOperationQueue.mainQueue().addOperationWithBlock(){
                let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("twitterService")
                self.presentViewController(nextController, animated: true, completion: nil)
            }
        } else {
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                simpleAlert("Tweet vide", message: "Ne peux envoyer un tweet vide")
            }
        }
        //        }
        //    }
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newLength = (tweetField.text!.utf16.count + string.utf16.count) - range.length
        counterLabel.text =  String(newLength)
        return newLength < 140
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tweetField.delegate = self
        counterLabel.text = "0"
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
