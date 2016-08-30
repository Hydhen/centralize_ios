//
//  DriveFileController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 15/08/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

let root = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String

class DriveFileController: UIViewController {

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
    @IBOutlet weak var openButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var downloadButton: UIBarButtonItem!

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
    
    @IBAction func openButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: current_file.valueForKey("webViewLink") as! String)!)
    }
    @IBAction func downloadButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: current_file.valueForKey("webContentLink") as! String)!)
        
        //        self.disableUI()
        //
        //        let fileManager = NSFileManager.defaultManager()
        //
        //        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        //        let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        //        let url = NSURL(string: current_file.valueForKey("webContentLink")! as! String)
        //        let request = NSMutableURLRequest(URL: url!)
        //        request.HTTPMethod = "GET"
        //
        //        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
        //            if (error == nil) {
        //                let statusCode = (response as! NSHTTPURLResponse).statusCode
        //                print("Success: \(statusCode)")
        //
        //                var writeError:NSError?
        //
        //                let file = data?.writeToFile(root + "/\(self.fileName.text!)", atomically: true)
        //
        //                print ("Wrote on disk")
        //
        //                print ("Opened on disk :")
        //                // TODO: COMPRENDRE POURQUOI J'AI PAS LE FICHIER MAIS UNE PAGE WEB EN SORTI
        //                do {
        //                    let text = try NSString(contentsOfFile: root + "/\(self.fileName.text!)", usedEncoding: nil)
        //
        //                    print (text)
        //                }
        //                catch {
        //                    print ("read failed")
        //                }
        //                self.enableUI()
        //            }
        //            else {
        //                print("Failure: %@", error!.localizedDescription)
        //
        //                let alertController = UIAlertController(title: "Failed to download", message: "Failed to download \(self.fileName.text), please try again later", preferredStyle: UIAlertControllerStyle.Alert)
        //                
        //                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        //                
        //                self.enableUI()
        //            }
        //        })
        //        task.resume()
    }
    
    func setStatics() {
        self.navigationBar.title = t.valueForKey("DRIVE_DETAILS")! as? String
        self.fileSizeLabel.text = t.valueForKey("DRIVE_SIZE")! as? String
        self.fileCreationDateLabel.text = t.valueForKey("DRIVE_CREATION")! as? String
        self.fileModificationLabel.text = t.valueForKey("DRIVE_MODIFICATION")! as? String
        self.openButton.title = t.valueForKey("DRIVE_OPEN_IN_BROWSER")! as? String
        self.shareButton.title = t.valueForKey("DRIVE_SHARE")! as? String
        self.downloadButton.title = t.valueForKey("DRIVE_DOWNLOAD")! as? String
        
        if current_file.valueForKey("webViewLink") as? String == nil {
            self.openButton.enabled = false
        }
        
        if current_file.valueForKey("capabilities")!.valueForKey("canShare") as? Int == 1 {
            self.shareButton.enabled = true
        } else {
            self.shareButton.enabled = false
        }
        if current_file.valueForKey("webContentLink") as? String == nil {
            self.downloadButton.enabled = false
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
