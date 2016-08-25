//
//  DriveController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 15/08/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

var current_file: NSDictionary = [:]

class DriveController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var noFileLabel: UILabel!
    @IBOutlet weak var parentFolderButton: UIButton!
    @IBOutlet weak var currentFolder: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBAction func homeButtonPressed(sender: AnyObject) {
        NSOperationQueue.mainQueue().addOperationWithBlock(){
            let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("homeController")
            self.presentViewController(nextController, animated: true, completion: nil)
        }
    }

    var history = [
        ("root", t.valueForKey("DRIVE_ROOT")! as? String),
    ]
    
    var files : NSMutableArray = []
    
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
    
    func fetchFiles(path: String? = "") {
        self.disableUI()
        self.tableView.hidden = true
        self.noFileLabel.hidden = true
        self.imageView.hidden = false
        self.currentFolder.hidden = true
        let session = APIGETSession("/drive/getfiles/\(current_service)/" + (path != "" ? "?folder=" + path! : ""))
        
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
                
                self.files = (jsonResult["files"]! as? NSMutableArray)!
                print ("--- files")
                print (self.files)
                print("files ---")

                let nbFiles = self.files.count
                
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    if nbFiles == 0 {
                        self.noFileLabel.hidden = false
                    } else {
                        self.tableView.reloadData()
                        self.tableView.hidden = false
                    }
                    self.imageView.hidden = true
                    self.currentFolder.hidden = false
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
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        if history.count > 1 {
            history.popLast()!
        }
        if history.count == 1 {
            self.parentFolderButton.hidden = true
        }
        
        let parent: (id: String, name: String?) = history.last!

        self.currentFolder.text = parent.name
        self.fetchFiles(parent.id)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.title = t.valueForKey("DRIVE")! as? String
        self.parentFolderButton.setTitle(t.valueForKey("DRIVE_BACK")! as? String, forState: UIControlState.Normal)
        self.parentFolderButton.hidden = true
        self.currentFolder.text = t.valueForKey("DRIVE_ROOT")! as? String
        self.currentFolder.hidden = true
        self.tableView.hidden = true
        self.noFileLabel.text = t.valueForKey("DRIVE_NO_FILE")! as? String
        self.noFileLabel.hidden = true
        self.imageView.image = getImageLoader()
        self.imageView.hidden = true
        self.backButton.title = t.valueForKey("BACK")! as? String
    }
    override func viewDidAppear(animated: Bool) {
        self.fetchFiles()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.files.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let file = (self.files[indexPath.row] as? NSDictionary)!

        let cell = self.tableView.dequeueReusableCellWithIdentifier("FileListCell", forIndexPath: indexPath) as! FileListCell
        cell.fileName.text = file.valueForKey("name") as? String
        return cell
    }
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let file = (self.files[indexPath.row] as? NSDictionary)!

        print ("--- file selected")
        print (file)
        print ("file selected ---")
        
        let file_type = file.valueForKey("mimeType") as! String
        
        if (file_type == "application/vnd.google-apps.folder") {
            let child_id = file.valueForKey("id") as! String
            let child_name = file.valueForKey("name") as! String

            self.history.append((child_id, child_name))
            
            print ("--- history")
            print (history)
            print ("history ---")
            
            NSOperationQueue.mainQueue().addOperationWithBlock(){
                self.parentFolderButton.hidden = false
                self.currentFolder.text = child_name
                self.fetchFiles(child_id)
            }
        } else {
            current_file = file

            NSOperationQueue.mainQueue().addOperationWithBlock(){
                let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("driveFile")
                self.presentViewController(nextController, animated: true, completion: nil)
            }
        }

        return indexPath
    }
}
