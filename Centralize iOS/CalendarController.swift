//
//  CalendarController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 04/07/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

var current_calendar: String = ""

class CalendarController: UIViewController {
    
    @IBOutlet weak var noCalendarsLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationItem!

    var calendarsList: NSMutableArray = []
    
    @IBAction func homeButtonPressed(sender: AnyObject) {
        NSOperationQueue.mainQueue().addOperationWithBlock(){
            let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("homeController")
            self.presentViewController(nextController, animated: true, completion: nil)
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
    
    func loadCalendars() {
        self.disableUI()
        let session = APIGETSession("/googlecalendar/getcalendars/\(current_service)/")
        
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
                
                print (jsonResult)
                
                self.calendarsList = (jsonResult.valueForKey("items")! as? NSMutableArray)!
                
                let nbCalendars = self.calendarsList.count
                
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    if nbCalendars == 0 {
                        self.noCalendarsLbl.hidden = false
                    } else {
                        self.tableView.reloadData()
                        self.tableView.hidden = false
                    }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.hidden = true
        self.navigationBar.title = t.valueForKey("CALENDAR_LIST_TITLE")! as? String
        self.noCalendarsLbl.text = t.valueForKey("CALENDAR_NO_CALENDARS")! as? String
        self.noCalendarsLbl.hidden = true
        self.imageView.image = getImageLoader()
    }
    override func viewDidAppear(animated: Bool) {
        self.loadCalendars()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.calendarsList.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let calendar = (self.calendarsList[indexPath.row] as? NSDictionary)!
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        cell.textLabel?.text = (calendar.valueForKey("summary")! as? String)!
        return cell
    }
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let calendar = (self.calendarsList[indexPath.row] as? NSDictionary)!
        current_calendar = (calendar.valueForKey("id")! as? String)!
        NSOperationQueue.mainQueue().addOperationWithBlock(){
            let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("calendarEventList")
            self.presentViewController(nextController, animated: true, completion: nil)
        }
        return indexPath
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
