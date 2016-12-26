//
//  SlackChannelPopUpController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 13/11/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class SlackChannelPopUpController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    
    let channels = current_slack_channels
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cancelButton.setTitle("Cancel", forState: UIControlState.Normal) // TODO
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.showAnimate()
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
        self.view.alpha = 0.0;
        UIView.animateWithDuration(0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animateWithDuration(0.25, animations: {
            self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.view.removeFromSuperview()
                }
        });
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        self.removeAnimate()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let channel = (self.channels[indexPath.row] as? NSDictionary)!
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("slackChannelPopUpListCell", forIndexPath: indexPath)
        cell.textLabel!.text = channel.valueForKey("name") as? String
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        print("channel selected: \(self.channels[indexPath.row])")
        let channel = self.channels[indexPath.row] as! NSDictionary
        
        let message = "\(slack_current_message.text!)\(channel["name"]!)"
        slack_current_message.text = message
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            self.removeAnimate()
        }
        return indexPath
    }
    
}
