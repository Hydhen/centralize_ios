//
//  ServiceController.swift
//  Centralize iOS
//
//  Created by Max Prudhomme on 13/04/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class ServiceController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var menuBar: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    var serviceTitle: NSMutableArray = []
    var serviceId: NSMutableArray = []
    
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
        self.menuBar.title = t.valueForKey("SERVICES")! as? String
        self.imageView.image = getImageLoader()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.loadServices()
    }
    
    func loadServices() {
        self.disableUI()
        
        let session = APIGETSession("/user-services/dashboard/\(current_dashboard)/")
        
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

                let nbServices = jsonResult["count"] as! Int
                let services = jsonResult["results"] as! NSArray
                
                if nbServices > 0 {
                    for i in 0...(nbServices - 1) {
                        let service = services[i] as! NSDictionary
                        let serviceInformation = service["service"] as! NSDictionary
                        
                        self.serviceTitle.addObject(serviceInformation["title"]!)
                        self.serviceId.addObject(serviceInformation["dev_title"]!)
                    }
                }

                NSOperationQueue.mainQueue().addOperationWithBlock(){
                    self.tableView.reloadData()
                    self.imageView.hidden = true
                    self.tableView.hidden = false
                    self.enableUI()
                }

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.serviceTitle.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        cell.textLabel?.text = self.serviceTitle[indexPath.row] as? String
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let service_selected = (self.serviceId[indexPath.row] as? String)!
        NSOperationQueue.mainQueue().addOperationWithBlock(){
            let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let nextController = currentStoryboard.instantiateViewControllerWithIdentifier(service_selected + "Service")
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
