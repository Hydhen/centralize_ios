//
//  CalendarEventSearchController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 08/07/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class CalendarEventSearchController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var startDateTimeLabel: UILabel!
    @IBOutlet weak var startDateTimePicker: UIDatePicker!
    @IBOutlet weak var endDateTimeLabel: UILabel!
    @IBOutlet weak var endDateTimePicker: UIDatePicker!
    @IBOutlet weak var noEventLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!

    let RFC3339DateFormatter = NSDateFormatter()
    let humanReadableDateFormatter = NSDateFormatter()
    var eventList: NSMutableArray = []

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

    @IBAction func searchBtnAction(sender: AnyObject) {
        let allowed = NSMutableCharacterSet.alphanumericCharacterSet()
        allowed.addCharactersInString("-")

        let compareResult = self.startDateTimePicker.date.compare(self.endDateTimePicker.date)

        print ("self.startDateTimePicker.date: \(self.startDateTimePicker.date)")
        print ("self.endDateTimePicker.date: \(self.endDateTimePicker.date)")

        if compareResult == NSComparisonResult.OrderedDescending {
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                simpleAlert((t.valueForKey("CALENDAR_EVENT_START_LATER_THAN_END")! as? String)!, message: (t.valueForKey("CALENDAR_EVENT_START_LATER_THAN_END_DESC")! as? String)!)
            }
        } else {
            self.disableUI()
            self.noEventLabel.hidden = true
            self.imageView.hidden = false

            let timeMinDate = self.startDateTimePicker.date
            var timeMinString = RFC3339DateFormatter.stringFromDate(timeMinDate)
            timeMinString = timeMinString.stringByAddingPercentEncodingWithAllowedCharacters(allowed)!

            let timeMaxDate = self.endDateTimePicker.date
            var timeMaxString = RFC3339DateFormatter.stringFromDate(timeMaxDate)
            timeMaxString = timeMaxString.stringByAddingPercentEncodingWithAllowedCharacters(allowed)!

            print("timeMinString: \(timeMinString)")
            print("timeMaxString: \(timeMaxString)")
            
            print("url: /api/googlecalendar/getevents/\(current_service)/calendar/\(current_calendar)/?timeMin=\(timeMinString)&timeMax=\(timeMaxString)")
            
            let session = APIGETSession("/googlecalendar/getevents/\(current_service)/calendar/\(current_calendar)/?timeMin=\(timeMinString)&timeMax=\(timeMaxString)")
            
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
                    
                    print(jsonResult)
                    
                    self.eventList = (jsonResult.valueForKey("items")! as? NSMutableArray)!
                    
                    let nbEvents = self.eventList.count
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        if nbEvents == 0 {
                            self.noEventLabel.hidden = false
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.humanReadableDateFormatter.dateStyle = .MediumStyle
        self.humanReadableDateFormatter.timeStyle = .NoStyle
        if currentLanguage == "en" {
            self.RFC3339DateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            self.humanReadableDateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        } else {
            self.RFC3339DateFormatter.locale = NSLocale(localeIdentifier: "fr_FR_POSIX")
            self.humanReadableDateFormatter.locale = NSLocale(localeIdentifier: "fr_FR")
        }
        self.RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxx"
        self.RFC3339DateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        self.imageView.image = getImageLoader()
        self.imageView.hidden = true
        self.navigationBar.title = t.valueForKey("CALENDAR_LIST_EVENT_TITLE")! as? String
        self.noEventLabel.text = t.valueForKey("CALENDAR_LIST_EVENT_NO_EVENT")! as? String
        self.noEventLabel.hidden = true
        self.tableView.hidden = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.eventList.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let event = (self.eventList[indexPath.row] as? NSDictionary)!
        
        print("Event: \(event)")

        let text = event.valueForKey("summary") as? String
        let start = event.valueForKey("start")!.valueForKey("dateTime") as? String
        var humanReadableDate = ""
        
        if start == nil {
            humanReadableDate = (t.valueForKey("CALENDAR_TIME_ALLDAY")! as? String)!
        } else {
            let date = self.RFC3339DateFormatter.dateFromString(start!)
            humanReadableDate = self.humanReadableDateFormatter.stringFromDate(date!)
        }
        print (humanReadableDate)
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("EventListCell", forIndexPath: indexPath) as! EventListCell
        print (cell)
        if text == nil {
            cell.eventName.text = t.valueForKey("CALENDAR_EVENT_UNNAMED")! as? String
            cell.eventDate.text = t.valueForKey("CALENDAR_TIME_ALLDAY")! as? String
        } else {
            print(text)
            print(cell.eventName)
//            cell.eventName.text = "Toto"
//            print(text)
////            print(humanReadableDate)
//            cell.eventDate.text = humanReadableDate
        }
        
        return cell
    }
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let event = (self.eventList[indexPath.row] as? NSDictionary)!
        current_event = event
        NSOperationQueue.mainQueue().addOperationWithBlock(){
            let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("calendarEventDetails")
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
