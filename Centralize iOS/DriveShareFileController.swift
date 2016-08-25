//
//  DriveShareFileController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 24/08/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class DriveShareFileController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var navigationBar: UINavigationItem!

    @IBOutlet weak var receivers: UITextField!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var permissionPicker: UIPickerView!

    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var permissions: NSArray = [
        (t.valueForKey("DRIVE_RIGHT_READER")! as? String)!,
        (t.valueForKey("DRIVE_RIGHT_WRITER")! as? String)!,
    ]
    
    let permissionsAPI: NSArray = ["reader", "writer"]
    
    var permissionChoosen: Int = 0

    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    @IBAction func shareButtonPressed(sender: AnyObject) {
        print ("Partage à \(receivers.text) avec les droits \(permissions[permissionChoosen]) notification \(notificationSwitch.on)")
        
        if isValidEmail(receivers.text!) == true {
            //TODO: SEND SHARING REQUEST TO API
            let id = current_file.valueForKey("id")! as? String
            
            var stringPost: String = "send_email=\((notificationSwitch.on ? "1" : "0"))"
            let allowed = NSMutableCharacterSet.alphanumericCharacterSet()
            allowed.addCharactersInString("-")

            stringPost = stringPost.stringByAddingPercentEncodingWithAllowedCharacters(allowed)!
            let session = APIPOSTSession("/drive/addpermission/\(current_service)/file/\(id!)/" + "?email=\(self.receivers.text!)" + "&role=\(permissionsAPI[permissionChoosen])", data_string: stringPost)
            
            print ("/drive/addpermission/\(current_service)/file/\(id!)/" + "?email=\(self.receivers.text!)" + "&role=\(permissionsAPI[permissionChoosen])")
            print (stringPost)
            
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

        } else {
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                simpleAlert((t.valueForKey("DRIVE_WRONG_EMAIL_TITLE")! as? String)!, message: (t.valueForKey("DRIVE_WRONG_EMAIL_MESSAGE")! as? String)!)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.title = t.valueForKey("DRIVE_SHARE")! as? String
        self.receivers.placeholder = t.valueForKey("DRIVE_SHARE_RECEIVER")! as? String
        self.notificationLabel.text = t.valueForKey("DRIVE_SHARE_NOTIFICATION")! as? String
        self.backButton.title = t.valueForKey("BACK")! as? String
        self.shareButton.title = t.valueForKey("DRIVE_SHARE")! as? String

        self.permissionPicker.delegate = self
        self.permissionPicker.dataSource = self
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return permissions.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return permissions[row] as? String
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.permissionChoosen = row
        print (permissions[row])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
