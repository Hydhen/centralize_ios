//
//  RedditQuestionDetailsController.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 23/12/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class RedditQuestionDetailsController: UIViewController, UITabBarDelegate, UIWebViewDelegate {
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.title = (current_reddit_question["data"]!["title"]! as? String)
        self.userName.text = current_reddit_question["data"]!["author"]! as? String
        self.webView.loadHTMLString(current_reddit_question["data"]!["selftext"] as! String, baseURL: nil)
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if (item.tag == 0) {
            NSOperationQueue.mainQueue().addOperationWithBlock(){
                let currentStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let nextController = currentStoryboard.instantiateViewControllerWithIdentifier("redditAnswer")
                self.presentViewController(nextController, animated: true, completion: nil)
            }
        }
    }
}
