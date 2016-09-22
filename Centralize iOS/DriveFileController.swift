//
//  DriveFileController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 15/08/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

let root = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String

class DriveFileController: UIViewController, UITabBarDelegate {

    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var fileName: UILabel!

    @IBOutlet weak var readAccessImageView: UIImageView!
    @IBOutlet weak var commentAccessImageView: UIImageView!
    @IBOutlet weak var copyAccessImageView: UIImageView!
    @IBOutlet weak var editAccessImageView: UIImageView!
    @IBOutlet weak var shareAccessImageView: UIImageView!

    @IBOutlet weak var fileSizeLabel: UILabel!
    @IBOutlet weak var fileSize: UILabel!
    @IBOutlet weak var fileCreationDateLabel: UILabel!
    @IBOutlet weak var fileCreationDate: UILabel!
    @IBOutlet weak var fileModificationLabel: UILabel!
    @IBOutlet weak var fileModification: UILabel!

    @IBOutlet weak var backButton: UIBarButtonItem!

    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var downloadTab: UITabBarItem!
    @IBOutlet weak var openTab: UITabBarItem!
    @IBOutlet weak var shareTab: UITabBarItem!

    let bytesFormatter = NSByteCountFormatter()
    let RFC3339DateFormatter = NSDateFormatter()
    let humanReadableDateFormatter = NSDateFormatter()

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
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        print ("selected : \(item.tag)")
        if (item.tag == 0) {
            UIApplication.sharedApplication().openURL(NSURL(string: current_file.valueForKey("webContentLink") as! String)!)
        } else if (item.tag == 1) {
            UIApplication.sharedApplication().openURL(NSURL(string: current_file.valueForKey("webViewLink") as! String)!)
        } else if (item.tag == 2) {
            NSOperationQueue.mainQueue().addOperationWithBlock(){
                let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("driveShareFileController")
                self.presentViewController(nextController, animated: true, completion: nil)
            }
        }
    }

    func setStatics() {
        self.navigationBar.title = t.valueForKey("DRIVE_DETAILS")! as? String
        self.fileSizeLabel.text = t.valueForKey("DRIVE_SIZE")! as? String
        self.fileCreationDateLabel.text = t.valueForKey("DRIVE_CREATION")! as? String
        self.fileModificationLabel.text = t.valueForKey("DRIVE_MODIFICATION")! as? String
        self.downloadTab.title = t.valueForKey("DRIVE_DOWNLOAD")! as? String
        self.openTab.title = t.valueForKey("DRIVE_OPEN_IN_BROWSER")! as? String
        self.shareTab.title = t.valueForKey("DRIVE_SHARE")! as? String
        
        if current_file.valueForKey("webViewLink") as? String == nil {
            self.openTab.enabled = false
        }
        
        if current_file.valueForKey("capabilities")!.valueForKey("canShare") as? Int == 1 {
            self.shareTab.enabled = true
        } else {
            self.shareTab.enabled = false
        }
        if current_file.valueForKey("webContentLink") as? String == nil {
            self.downloadTab.enabled = false
        }
    }
    func setDynamicsLabel() {
        // File name
        self.fileName.text = current_file.valueForKey("name")! as? String

        // File size
        let size = current_file.valueForKey("size")
        if size == nil {
            self.fileSize.text = t.valueForKey("DRIVE_SIZE_NULL")! as? String
        } else {
            let strSize = size as! String
            let size: Int64 = Int64(strSize)!

            self.fileSize.text = bytesFormatter.stringFromByteCount(size)
        }
        
        // File date
        let createdTime = current_file.valueForKey("createdTime")! as? String
        var createdDate = ""
        
        for i in 0...9 {
            createdDate += String(createdTime![createdTime!.startIndex.advancedBy(i)])
        }
        
        let humanReadableCreatedDate = RFC3339DateFormatter.dateFromString(createdDate)
        self.fileCreationDate.text = humanReadableDateFormatter.stringFromDate(humanReadableCreatedDate!)
        
        let modifiedTime = current_file.valueForKey("modifiedTime") as? String
        var modifiedDate = ""
        
        if modifiedTime != nil {
            for i in 0...9 {
                modifiedDate += String(modifiedTime![modifiedTime!.startIndex.advancedBy(i)])
            }
            let humanReadableModifiedDate = RFC3339DateFormatter.dateFromString(modifiedDate)
            self.fileModification.text = humanReadableDateFormatter.stringFromDate(humanReadableModifiedDate!)

        } else {
            self.fileModificationLabel.hidden = true
            self.fileModification.hidden = true
        }
    }
    func setDynamicsImage() {
        let capabilities = current_file.valueForKey("capabilities")!
        
        if capabilities.valueForKey("canReadRevisions") as? Int == 1 {
            self.readAccessImageView.image = UIImage(named: "read-enabled-64")
        } else {
            self.readAccessImageView.image = UIImage(named: "read-disabled-64")
        }
        if capabilities.valueForKey("canComment") as? Int == 1 {
            self.commentAccessImageView.image = UIImage(named: "comment-enabled-64")
        } else {
            self.commentAccessImageView.image = UIImage(named: "comment-disabled-64")
        }
        if capabilities.valueForKey("canCopy") as? Int == 1 {
            self.copyAccessImageView.image = UIImage(named: "copy-enabled-64")
        } else {
            self.copyAccessImageView.image = UIImage(named: "copy-disabled-64")
        }
        if capabilities.valueForKey("canEdit") as? Int == 1 {
            self.editAccessImageView.image = UIImage(named: "write-enabled-64")
        } else {
            self.editAccessImageView.image = UIImage(named: "write-disabled-64")
        }
        if capabilities.valueForKey("canShare") as? Int == 1 {
            self.shareAccessImageView.image = UIImage(named: "share-enabled-64")
        } else {
            self.shareAccessImageView.image = UIImage(named: "share-disabled-64")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Date Formatter
        self.humanReadableDateFormatter.dateStyle = .MediumStyle
        self.humanReadableDateFormatter.timeStyle = .NoStyle
        if currentLanguage == "fr" {
            self.RFC3339DateFormatter.locale = NSLocale(localeIdentifier: "fr_FR_POSIX")
            self.humanReadableDateFormatter.locale = NSLocale(localeIdentifier: "fr_FR")
        } else {
            self.RFC3339DateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            self.humanReadableDateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        }
        self.RFC3339DateFormatter.dateFormat = "yyyy-MM-dd"
        self.RFC3339DateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)

        // Fill view with data
        self.setStatics()
        self.setDynamicsLabel()
        self.setDynamicsImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
