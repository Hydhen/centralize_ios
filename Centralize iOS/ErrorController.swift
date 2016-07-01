//
//  ViewController.swift
//  Centralize iOS
//
//  Created by Max Prudhomme on 17/02/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class ErrorController: UIViewController {
    @IBOutlet weak var navbar: UINavigationItem!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBAction func clickHome(sender: AnyObject) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc : ViewController = mainStoryboard.instantiateViewControllerWithIdentifier("mainController") as! ViewController
        self.presentViewController(vc, animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.image.image = UIImage(named: "warning.png")
        self.label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam ultrices mi in lorem convallis, vel dapibus massa bibendum. Phasellus non maximus velit. Sed pellentesque sit amet ante sed volutpat. Nulla bibendum magna leo, id vehicula ex aliquet sed. Nullam eleifend ac arcu vel gravida. Quisque tempor, orci sit amet tempor tincidunt, neque sapien cursus enim, et feugiat felis elit at justo. Curabitur sit amet tellus ac velit lobortis tincidunt eu in lorem."
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
