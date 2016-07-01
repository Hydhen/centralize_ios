//
//  MenuController.swift
//  Centralize iOS
//
//  Created by Max Prudhomme on 07/04/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class MenuController: UITableViewController {

    
    
    @IBOutlet weak var dashboardLink: UILabel!
    @IBOutlet weak var profileLink: UILabel!
    @IBOutlet weak var languagesLink: UILabel!
    @IBOutlet weak var passwordLink: UILabel!
    @IBOutlet weak var faqLink: UILabel!
    @IBOutlet weak var assistanceLink: UILabel!
    @IBOutlet weak var contactLink: UILabel!
    @IBOutlet weak var signoutLink: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.dashboardLink.text = (t.valueForKey("DASHBOARDS")! as? String)!
        self.profileLink.text = (t.valueForKey("PROFILE")! as? String)!
        self.languagesLink.text = (t.valueForKey("LANGUAGES")! as? String)!
        self.passwordLink.text = (t.valueForKey("EDIT_PASSWORD")! as? String)!
        self.faqLink.text = (t.valueForKey("FAQ")! as? String)!
        self.assistanceLink.text = (t.valueForKey("ASSISTANCE")! as? String)!
        self.contactLink.text = (t.valueForKey("CONTACT")! as? String)!
        self.signoutLink.text = (t.valueForKey("SIGN_OUT")! as? String)!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var name = ""
        switch (section) {
        case 0:
            name = (t.valueForKey("HOME")! as? String)!
            break
        case 1:
            name = (t.valueForKey("ACCOUNT")! as? String)!
            break
        case 2:
            name = (t.valueForKey("HELP")! as? String)!
            break
        case 3:
            name = ""
            break
        default:
            name = "None"
            break
        }
        return name
    }

    // MARK: - Table view data source

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
