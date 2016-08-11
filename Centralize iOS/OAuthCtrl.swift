//
//  OAuthCtrl.swift
//  Centralize iOS
//
//  Created by Max Prudhomme on 06/04/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit


//  URLs API
public struct APIConstants {
//    static let site_url = "https://www.centralizeproject.com";
//    static let url = "https://www.centralizeproject.com/api";
    static let site_url = "https://dev.centralizeproject.com/"
    static let url = "https://dev.api.centralizeproject.com"
}


class OAuthCtrl {
    var client_id = "PWkVY8GgolJN9nDPTyI3qYNZU0if"
    var client_secret = "962Sp5m5u8OMDzq6dMAFtEnzCUUIB9wfSNrvlqTl9NKoy1wTyvu4E9xqhgEOGc5zGa0tqw7OjLQVfiCjHEXS0sZgBTkJ6ITgqEZ3"
    
    func refresh_token(call: (success:Bool, title: String, message: String, data:NSDictionary) -> Void) {
        let url = NSURL(string: APIConstants.url + "/o/token/")
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url!)
        
        let token_access:NSDictionary = NSUserDefaults.standardUserDefaults().objectForKey("token_access") as! NSDictionary
        let token = token_access.valueForKey("access_token")! as! String
        
        request.HTTPMethod = "POST"
        let stringPost = "grant_type=refresh_token"
            + "&client_id=" + self.client_id
            + "&client_secret=" + self.client_secret
            + "&refresh_token=" + token
        
        print("OAUTH STRINGPOST: \(stringPost)")
        
        let data = stringPost.dataUsingEncoding(NSUTF8StringEncoding)
        
        request.timeoutInterval = 30
        request.HTTPBody = data
        request.HTTPShouldHandleCookies = false
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            do {
                if data == nil {
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        call(success: false, title: (t.valueForKey("CEN_NO_DATA_RECEIVED")! as? String)!, message: (t.valueForKey("CEN_NO_DATA_RECEIVED_DESC")! as? String)!, data: [:])
                    }
                    return
                }
                let jsonResult:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                print("JSON OAUTH:\(jsonResult)")
                
                if jsonResult["error"] != nil {
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        if jsonResult["error"]! as! String == "invalid_grant" {
                            call(success: false, title: (t.valueForKey("ACCOUNT_UNKNOWN")! as? String)!, message: (t.valueForKey("ACCOUNT_UNKNOWN_DESC")! as? String)!, data: jsonResult)
                        } else {
                            call(success: false, title: (t.valueForKey("CONNECTION_ERROR")! as? String)!, message: (t.valueForKey("CONNECTION_ERROR_DESC")! as? String)!, data: jsonResult)
                        }
                    }
                } else {
                    NSUserDefaults.standardUserDefaults().setObject(jsonResult, forKey: "token_access")
                    call(success: true, title: "", message: "", data: jsonResult)
                }
            }
            catch {
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    call(success: false, title: (t.valueForKey("CEN_NOT_REACHABLE")! as? String)!, message: (t.valueForKey("CEN_NOT_REACHABLE_DESC")! as? String)!, data: [:])
                }
            }
        })
        task.resume()
    }
}