//
//  GithubStatisticController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 26/11/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

var stats_count_down: Int = 0

class GithubStatisticController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var noStatLbl: UILabel!
    
    var stats: NSMutableArray = []
    
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
    
    func fetchStats() -> Int {
        self.disableUI()
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            self.tableView.hidden = true
            self.imageView.hidden = false
        }
        
        print ("SERVICE_ID: \(current_service)")
        print ("REQUEST: \("/github/getstats/\(current_service)/?owner=\(current_github_repository.valueForKey("owner")?.valueForKey("login")! as! String)&repo=\(current_github_repository.valueForKey("name")! as! String)")")
        let session: NSArray = APIGETSession("/github/getstats/\(current_service)/?owner=\(current_github_repository.valueForKey("owner")?.valueForKey("login")! as! String)&repo=\(current_github_repository.valueForKey("name")! as! String)")

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
                
                print (response)
                let res = response! as! NSHTTPURLResponse
                print (res)
                print (res.statusCode)
                if (res.statusCode == 202) {
                    return
//                    sleep(2)
//                    print ("STATS")
//                    print (stats_count_down)
//                    if stats_count_down == 2 {
//                        NSOperationQueue.mainQueue().addOperationWithBlock() {
//                            let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
//                            let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("githubService") as! GithubRepositoryController
//                            self.presentViewController(nextController, animated: true, completion: nil)
//                            self.enableUI()
//                        }
//                    } else {
//                        stats_count_down += 1
//                        self.fetchStats()
//                    }
                } else {
                    let jsonResult:NSMutableArray = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSMutableArray

                    if jsonResult.count <= 0 {
                        NSOperationQueue.mainQueue().addOperationWithBlock() {
                            self.enableUI()
                            simpleAlert((t.valueForKey("CEN_NOT_REACHABLE")! as? String)!, message: "No data retrieved" /* TODO */)
                            let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                            let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("GithubRepositoryController")
                            self.presentViewController(nextController, animated: true, completion: nil)
                        }
                    } else {
                        self.stats = jsonResult
                        NSOperationQueue.mainQueue().addOperationWithBlock() {
                            self.tableView.reloadData()
                            self.tableView.hidden = false
                            self.imageView.hidden = true
                            self.enableUI()
                        }
                    }
                }
            }
            catch {
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    simpleAlert((t.valueForKey("CEN_NOT_REACHABLE")! as? String)!,
                        message: (t.valueForKey("CEN_NOT_REACHABLE_DESC")! as? String)!)
                }
                self.enableUI()
            }
        })
        task.resume()
        return 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.title = "Statistics" // TODO
        self.tableView.hidden = true
        self.imageView.image = getImageLoader()
        self.imageView.hidden = true
        self.noStatLbl.text = "No stats found" // TODO
        self.noStatLbl.hidden = true
        while (self.fetchStats() == 200) {
            print ("wait")
            sleep(1)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stats.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let stat = (self.stats[indexPath.row] as? NSDictionary)!
        print (stat)
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("githubStatisticCell", forIndexPath: indexPath) as! GithubStatisticCell
        cell.user.text = stat.valueForKey("author")!.valueForKey("login")! as? String
        let countStats: NSMutableArray = stat.valueForKey("weeks")! as! NSMutableArray
        var addition = 0
        var deletion = 0
        var commit = 0
        
        for item in countStats {
            addition += item.valueForKey("a")! as! Int
            deletion += item.valueForKey("d")! as! Int
            commit += item.valueForKey("c")! as! Int
        }
        cell.additionLbl.text = "Addition" // TODO
        cell.deletionLbl.text = "Deletion" // TODO
        cell.commitLbl.text = "Commit" // TODO
        cell.additionCountLbl.text = String(addition)
        cell.deletionCountLbl.text = String(deletion)
        cell.commitCountLbl.text = String(commit)
        return cell
    }
}
