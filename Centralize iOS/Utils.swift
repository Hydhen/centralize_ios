//
//  Utils.swift
//  Centralize iOS
//
//  Created by Max Prudhomme on 17/05/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

func getImageLoader() -> UIImage {
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
    
    return UIImage.animatedImageWithImages(images, duration: 1.0)!
}

func APIGETSession(url_part: String) -> NSArray {
    let url = NSURL(string: APIConstants.url + url_part)
    let request: NSMutableURLRequest = NSMutableURLRequest(URL: url!)
    let config = NSURLSessionConfiguration.defaultSessionConfiguration()
    
    request.HTTPMethod = "GET"
    
    let token_access:NSDictionary = NSUserDefaults.standardUserDefaults().objectForKey("token_access") as! NSDictionary
    
    //------------------------------------------------------//
    //------------------------------------------------------//
    //  UNIQUEMENT TANT QUE LA MIGRATION N'EST PAS FINIE    //
    //------------------------------------------------------//
    //------------------------------------------------------//

    let token = token_access.valueForKey("access_token")!
//    let token = token_access.valueForKey("refresh_token")!
    
    //------------------------------------------------------//
    //------------------------------------------------------//
    //  FIN DE L'HORREUR                                    //
    //------------------------------------------------------//
    //------------------------------------------------------//

    
    let authString = "Bearer \(token)"
    config.HTTPAdditionalHeaders = ["Authorization" : authString]
    
    request.timeoutInterval = 30
    request.HTTPShouldHandleCookies = false
    return [NSURLSession(configuration: config), request]
}

func APIPOSTSession(url_part: String, data_string: String) -> NSArray {
    let url = NSURL(string:APIConstants.url + url_part)
    let request: NSMutableURLRequest = NSMutableURLRequest(URL: url!)
    let config = NSURLSessionConfiguration.defaultSessionConfiguration()
    
    request.HTTPMethod = "POST"
    
    let token_access:NSDictionary = NSUserDefaults.standardUserDefaults().objectForKey("token_access") as! NSDictionary
    
    let token = token_access.valueForKey("access_token")!
    let authString = "Bearer \(token)"
    config.HTTPAdditionalHeaders = ["Authorization": authString]
    
    let data = data_string.dataUsingEncoding(NSUTF8StringEncoding)
    
    request.HTTPBody = data
    request.timeoutInterval = 30
    request.HTTPShouldHandleCookies = false
    return [NSURLSession(configuration: config), request]
}

func APIPATCHSession(url_part: String, data_string: String) -> NSArray {
    let url = NSURL(string: APIConstants.url + url_part)
    let request: NSMutableURLRequest = NSMutableURLRequest(URL: url!)
    let config = NSURLSessionConfiguration.defaultSessionConfiguration()
    
    request.HTTPMethod = "PATCH"
    
    let token_access:NSDictionary = NSUserDefaults.standardUserDefaults().objectForKey("token_access") as! NSDictionary
    
    let token = token_access.valueForKey("access_token")!
    let authString = "Bearer \(token)"
    config.HTTPAdditionalHeaders = ["Authorization" : authString, "Content-Type":"application/x-www-form-urlencoded"]
    
    let data = data_string.dataUsingEncoding(NSUTF8StringEncoding)
    
    request.HTTPBody = data
    request.timeoutInterval = 30
    request.HTTPShouldHandleCookies = false
    return [NSURLSession(configuration: config), request]
}

func simpleAlert(title: String, message: String) {
    let alertController = DBAlertController(title: title, message: message, preferredStyle: .Alert)
    alertController.addAction(UIAlertAction(title: t.valueForKey("OK")! as? String, style: .Default, handler: nil))
    alertController.show()
}