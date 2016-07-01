//
//  ViewController.swift
//  Centralize iOS
//
//  Created by Max Prudhomme on 17/02/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var faq_list: NSMutableArray = []

    @IBOutlet weak var tableViewFAQ: UITableView!
    @IBOutlet weak var imgView: UIImageView!
    
    func initLoader() {
        let img_1 = UIImage(named: "loader-1.png")!
        let img_2 = UIImage(named: "loader-2.png")!
        let img_3 = UIImage(named: "loader-3.png")!
        let img_4 = UIImage(named: "loader-4.png")!
        let img_5 = UIImage(named: "loader-5.png")!
        let img_6 = UIImage(named: "loader-6.png")!
        let img_7 = UIImage(named: "loader-7.png")!
        let img_8 = UIImage(named: "loader-8.png")!
        let img_9 = UIImage(named: "loader-9.png")!
        let img_10 = UIImage(named: "loader-10.png")!
        let img_11 = UIImage(named: "loader-11.png")!
        let img_12 = UIImage(named: "loader-12.png")!
        
        let images = [img_1, img_2, img_3, img_4, img_5, img_6, img_7, img_8, img_9, img_10, img_11, img_12]
        
        self.imgView.image = UIImage.animatedImageWithImages(images, duration: 1.0)
    }
    
    func loadFAQ() {
        self.getData({data, error -> Void in
            if (data != nil) {
                self.faq_list = NSMutableArray(array: data)
                NSOperationQueue.mainQueue().addOperationWithBlock(){
                    self.tableViewFAQ!.reloadData()
                    self.tableViewFAQ.hidden = false
                    self.imgView.hidden = true
                }
            } else {
                self.loadError()
                //print("api.getData failed")
            }
        })
    }
    
    func getData(completionHandler: ((NSArray!, NSError!) -> Void)!) -> Void {
        let url = NSURL(string: "http://zheness.ovh/faq.php")
        //let url = NSURL(string: "http://blabla.ovh/")
        //let url = NSURL(string: "http://www.maxprudhomme.fr/")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
            (data, response, error) -> Void in
            if let content_encrypted = data {
                do {
                    let jsonContent = try NSJSONSerialization.JSONObjectWithData(content_encrypted, options: .AllowFragments)
                
                    return completionHandler(jsonContent as! [NSDictionary], nil)
                } catch {
                    //print("no json")
                }
                //print("fin")
                return completionHandler(nil, nil)
            } else {
                return completionHandler(nil, error)
            }
        }
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initLoader()
        self.tableViewFAQ.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        //self.loadFAQ()
        
        let alert = UIAlertController(title: "Error", message: "An error has occured", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func loadError() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc : ErrorController = mainStoryboard.instantiateViewControllerWithIdentifier("errorController") as! ErrorController
        self.presentViewController(vc, animated: false, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.faq_list.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        cell.textLabel?.text = self.faq_list[indexPath.row]["question"] as? String
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
