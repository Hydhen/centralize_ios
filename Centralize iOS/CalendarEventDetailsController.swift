//
//  CalendarEventDetailsController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 04/07/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class CalendarEventDetailsController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!

    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var location: UILabel!

    var eventSummary: String? = current_event["summary"] as? String
    var eventDescription: String? = current_event["description"] as? String

    let RFC3339DateFormatter = NSDateFormatter()
    let humanReadableDateFormatter = NSDateFormatter()

    func getTimeFromDate(date: NSDate) -> (hour: String, minute: String) {
        
        let calendar = NSCalendar.currentCalendar()
        let hour = calendar.component([.Hour], fromDate: date)
        let minute = calendar.component([.Minute], fromDate: date)
        
        if minute == 0 {
            return (String(hour), "00")
        }
        
        return (String(hour), String(minute))
    }
    func setDateTime(dateStartString: String?, dateEndString: String?) {
        if dateStartString == nil || dateEndString == nil {
            self.date.text = t.valueForKey("CALENDAR_TIME_ALLDAY")! as? String
        } else {
            let dateStart = RFC3339DateFormatter.dateFromString(dateStartString!)
            let timeStart = self.getTimeFromDate(dateStart!)
            let dateEnd = RFC3339DateFormatter.dateFromString(dateEndString!)
            let timeEnd = self.getTimeFromDate(dateEnd!)
            
            self.date.text = "\(timeStart.hour):\(timeStart.minute) - \(timeEnd.hour):\(timeEnd.minute)"
        }
    }
    func setDescription() {
        let description = current_event["description"] as? String

        if description == nil || description == "" {
            self.descriptionTextView.text = t.valueForKey("CALENDAR_DETAILS_NO_DESCRIPTION") as? String
        } else {
            self.descriptionTextView.text = description!
        }
    }
    func setLocation() {
        let location = current_event["location"] as? String

        if location == nil || location == "" {
            self.location.text = t.valueForKey("CALENDAR_DETAILS_NO_LOCATION") as? String
        } else {
            self.location.text = location
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.descriptionLabel.text = t.valueForKey("CALENDAR_DETAILS_DESCRIPTION")! as? String
        self.humanReadableDateFormatter.dateStyle = .MediumStyle
        self.humanReadableDateFormatter.timeStyle = .NoStyle
        if currentLanguage == "en" {
            self.RFC3339DateFormatter.locale = NSLocale(localeIdentifier: "en_US")
            self.humanReadableDateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        } else {
            self.RFC3339DateFormatter.locale = NSLocale(localeIdentifier: "fr_FR")
            self.humanReadableDateFormatter.locale = NSLocale(localeIdentifier: "fr_FR")
        }
        self.RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        self.RFC3339DateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        
        if self.eventSummary == nil || self.eventSummary == "" {
            self.navigationBar.title = t.valueForKey("CALENDAR_EVENT_UNNAMED")! as? String
        } else {
            self.navigationBar.title = self.eventSummary
        }
        
        self.setDateTime(current_event.valueForKey("start")!.valueForKey("dateTime") as? String, dateEndString: current_event.valueForKey("end")!.valueForKey("dateTime") as? String)
        self.setDescription()
        self.setLocation()
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
