//
//  FacebookNewPostController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 23/10/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class FacebookNewPostController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!

    @IBAction func sendStatusOnClick(sender: AnyObject) {
        let allowed = NSMutableCharacterSet.alphanumericCharacterSet()
        allowed.addCharactersInString("-")

        var stringPost: String = "message="
        stringPost += textView.text!

        if (textView.text != nil && textView.text != "") {
            let session = APIPOSTSession("/facebook/status/\(current_service)/", data_string: stringPost)
            
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
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                simpleAlert("Status envoyé", message: "Votre status a été mis à jour") //TODO
            }
        } else {
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                simpleAlert("Status vide", message: "Ne peux envoyer un status vide") //TODO
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.sendButton.setTitle("Post status", forState: UIControlState.Normal) // TODO
    }

}
