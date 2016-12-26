//
//  FacebookNewPostController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 23/10/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class FacebookNewPostController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noStatusLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var status : NSMutableArray = []
    
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
    
    @IBAction func sendStatusOnClick(sender: AnyObject) {
        let allowed = NSMutableCharacterSet.alphanumericCharacterSet()
        allowed.addCharactersInString("-")

        var stringPost: String = "message="
        stringPost += self.textField.text!

        if (self.textField.text != nil && self.textField.text != "") {
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
    
    func fetchStatus() {
        self.disableUI()
        self.tableView.hidden = true
        self.noStatusLbl.hidden = true
        self.imageView.hidden = false
        let session = APIGETSession("/facebook/wall/\(current_service)/")
        
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
                
                if jsonResult.valueForKey("data") == nil {
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        simpleAlert((t.valueForKey("CEN_NOT_REACHABLE")! as? String)!, message: (jsonResult.valueForKey("details")! as? String)!)
                        let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                        let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("homeController")
                        self.presentViewController(nextController, animated: true, completion: nil)
                        self.enableUI()
                    }
                } else {
                    self.status = (jsonResult["data"]! as? NSMutableArray)!
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        if self.status.count == 0 {
                            self.noStatusLbl.hidden = false
                        } else {
                            self.tableView.reloadData()
                            self.tableView.hidden = false
                        }
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
        self.sendButton.setTitle("Post", forState: UIControlState.Normal) // TODO
        self.fetchStatus()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.status.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let st = (self.status[indexPath.row] as? NSDictionary)!
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("facebookStatusCell", forIndexPath: indexPath)
        cell.textLabel?.text = st.valueForKey("from")!.valueForKey("name") as? String
        cell.detailTextLabel?.text = st.valueForKey("message") as? String
        return cell
    }

}
