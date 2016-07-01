//
//  ProfileController.swift
//  Centralize iOS
//
//  Created by Max Prudhomme on 26/03/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class ProfileController: UITabBarController {
    
    var first_name = ""
    var last_name = ""
    var city = ""
    var country = ""
    var biography = ""
    var profile_id = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().tintColor = UIColor(red: 177/255, green: 14/255, blue: 0, alpha: 1)
        // Do any additional setup after loading the view.
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
