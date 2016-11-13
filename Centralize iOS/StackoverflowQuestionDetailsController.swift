//
//  StackoverflowQuestionDetailsController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 04/11/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class StackoverflowQuestionDetailsController: UIViewController, UITabBarDelegate, UIWebViewDelegate {

    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.title = (current_stackoverflow_question["title"]! as? String)
        let url = NSURL(string: current_stackoverflow_question["owner"]!["profile_image"]! as! String)
        let data = NSData(contentsOfURL: url!)
        let image = UIImage(data: data!)
        self.userImage.image = image
        self.userName.text = current_stackoverflow_question["owner"]!["display_name"]! as? String
        self.webView.loadHTMLString(current_stackoverflow_question["body"]! as! String, baseURL: nil)
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if (item.tag == 0) {
            NSOperationQueue.mainQueue().addOperationWithBlock(){
                let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("stackoverflowAnswer")
                self.presentViewController(nextController, animated: true, completion: nil)
            }
        }
    }
}
