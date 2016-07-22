//
//  CalendarEventCreateController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 08/07/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class CalendarEventCreateController: UIViewController {

    @IBOutlet weak var summary: UITextField!
    @IBOutlet weak var allDayLabel: UILabel!
    @IBOutlet weak var allDaySwitch: UISwitch!
    @IBOutlet weak var startDateTimeLabel: UILabel!
    @IBOutlet weak var startDateTimePicker: UIDatePicker!
    @IBOutlet weak var endDateTimeLabel: UILabel!
    @IBOutlet weak var endDateTimePicker: UIDatePicker!
    @IBOutlet weak var descriptionLabel: UITextField!
    @IBOutlet weak var location: UITextField!

    @IBAction func allDaySwitchAction(sender: AnyObject) {
        if self.allDaySwitch.on {
            self.startDateTimePicker.datePickerMode = UIDatePickerMode.Date
            self.endDateTimePicker.datePickerMode = UIDatePickerMode.Date
        } else {
            self.startDateTimePicker.datePickerMode = UIDatePickerMode.DateAndTime
            self.endDateTimePicker.datePickerMode = UIDatePickerMode.DateAndTime
        }
    }
    func createEvent(stringPatch: String) {
        print (stringPatch)
        self.disableUI()
        
        let session = APIPOSTSession("/googlecalendar/addevent/\(current_service)/calendar/\(current_calendar)/", data_string: stringPatch)
        
        let task = session[0].dataTaskWithRequest(session[1] as! NSURLRequest, completionHandler: {data, response, error -> Void in
            do {
                if data == nil {
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        simpleAlert((t.valueForKey("CEN_NO_DATA_RECEIVED")! as? String)!, message: (t.valueForKey("CEN_NO_DATA_RECEIVED_DESC")! as? String)!)
                        //                        self.imageView.hidden = true
                        self.enableUI()
                    }
                    return
                }

                print(data)
                print(response)
                print(error)
                
                let jsonResult:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                print("RESULT: \(jsonResult)")
                if jsonResult["details"] != nil && jsonResult["details"]! as! String == "An error occured" {
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        simpleAlert((t.valueForKey("ERROR")! as? String)!, message: (t.valueForKey("ERROR_DESC")! as? String)!)
                        self.enableUI()
                    }
                } else {
                    self.enableUI()
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        let calendarEventListController = storyBoard.instantiateViewControllerWithIdentifier("calendarEventList") as! CalendarEventListController
                        self.presentViewController(calendarEventListController, animated:true, completion:nil)
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
    @IBAction func createButtonAction(sender: AnyObject) {
        let dateFormatter = NSDateFormatter()
        var stringPatch: String = ""
        let allowed = NSMutableCharacterSet.alphanumericCharacterSet()
        allowed.addCharactersInString("-")
        
        if self.allDaySwitch.on {
            dateFormatter.dateFormat = "yyyy-MM-dd"
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxx"
        }
        
        let compareResult = self.startDateTimePicker.date.compare(self.endDateTimePicker.date)
        print (self.startDateTimePicker.date)
        print (self.endDateTimePicker.date)
        if compareResult == NSComparisonResult.OrderedDescending {
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                simpleAlert((t.valueForKey("CALENDAR_EVENT_START_LATER_THAN_END")! as? String)!, message: (t.valueForKey("CALENDAR_EVENT_START_LATER_THAN_END_DESC")! as? String)!)
            }
        } else {
            var dateString = dateFormatter.stringFromDate(self.startDateTimePicker.date)
            dateString = dateString.stringByAddingPercentEncodingWithAllowedCharacters(allowed)!
            stringPatch += "startDate=\(dateString)"
            print(stringPatch)
            dateString = dateFormatter.stringFromDate(self.endDateTimePicker.date)
            dateString = dateString.stringByAddingPercentEncodingWithAllowedCharacters(allowed)!
            stringPatch += "&endDate=\(dateString)"
            print(stringPatch)
            if self.summary.text == nil || self.summary.text! == "" {
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    simpleAlert((t.valueForKey("CALENDAR_SUMMARY_EMPTY")! as? String)!, message: (t.valueForKey("CALENDAR_SUMMARY_EMPTY_DESC")! as? String)!)
                }
            } else {
                let summary = self.summary.text!.stringByAddingPercentEncodingWithAllowedCharacters(allowed)!
                stringPatch += "&summary=\(summary)"
                print(stringPatch)
                if self.descriptionLabel.text != nil && self.descriptionLabel.text! != "" {
                    let description = self.descriptionLabel.text!.stringByAddingPercentEncodingWithAllowedCharacters(allowed)!
                    stringPatch += "&description=\(description)"
                    print(stringPatch)
                }
                if self.location.text != nil && self.location.text != "" {
                    let location = self.location.text!.stringByAddingPercentEncodingWithAllowedCharacters(allowed)!
                    stringPatch += "&location=\(location)"
                    print(stringPatch)
                }
                print(self.summary.text)
                print(self.allDaySwitch.on)
                print(self.startDateTimePicker.date)
                print(self.endDateTimePicker.date)
                print(self.descriptionLabel.text)
                print(self.location.text)
                self.createEvent(stringPatch)
            }
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
    
    func setDateTimePicker() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

        let today = NSDate()
        var startString: String? = dateFormatter.stringFromDate(today)
        var endString: String? = dateFormatter.stringFromDate(today)

        if startString == nil {
            startString = current_event["start"]!["date"] as? String
            endString = current_event["end"]!["date"] as? String
            self.allDaySwitch.on = true
            self.startDateTimePicker.datePickerMode = UIDatePickerMode.Date
            self.endDateTimePicker.datePickerMode = UIDatePickerMode.Date
            dateFormatter.dateFormat = "yyyy-MM-dd"
        }
        
        
        var date: NSDate = dateFormatter.dateFromString(startString!)!
        self.startDateTimePicker.date = date
        date = dateFormatter.dateFromString(endString!)!
        self.endDateTimePicker.date = date
    }
    func setPlaceHolder() {
        self.summary.placeholder = t.valueForKey("CALENDAR_EVENT_UNNAMED")! as? String
        self.descriptionLabel.placeholder = t.valueForKey("CALENDAR_DETAILS_NO_DESCRIPTION")! as? String
        self.location.placeholder = t.valueForKey("CALENDAR_DETAILS_NO_LOCATION")! as? String
    }
    func setTranslation() {
        self.allDayLabel.text = t.valueForKey("CALENDAR_TIME_ALLDAY")! as? String
        self.startDateTimeLabel.text = t.valueForKey("CALENDAR_EVENT_START")! as? String
        self.endDateTimeLabel.text = t.valueForKey("CALENDAR_EVENT_END")! as? String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.allDaySwitch.on = false
        if currentLanguage == "en" {
            self.startDateTimePicker.locale = NSLocale(localeIdentifier: "en_US")
            self.endDateTimePicker.locale = NSLocale(localeIdentifier: "en_US")
        } else {
            self.startDateTimePicker.locale = NSLocale(localeIdentifier: "fr_FR")
            self.endDateTimePicker.locale = NSLocale(localeIdentifier: "fr_FR")
        }
        self.setDateTimePicker()
        self.setPlaceHolder()
        self.setTranslation()
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
