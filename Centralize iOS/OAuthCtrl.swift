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
//    static let site_url = "https://centralize-dev.develfactory.net";
//    static let url = "https://centralize-dev.develfactory.net/api";
    static let site_url = "https://www.centralizeproject.com";
    static let url = "https://www.centralizeproject.com/api";
}


class OAuthCtrl {
    var client_id = "5ykcWfdhN5yy9tjqctACqoTkUL3i50WKS6kmWYfO"
    var client_secret = "cSNc3LmtWDYN8tG7RwoUXGkbi6ycD4eBdlde0Rn7UZBOg103GDVCwYQ8O5tFkLWEuQ7FlH0CzKBvA9u3gJyNc9XKm9YKH5SZ9F0KUqJ6He1tungG6vPRXn9EMPnPK0sC"
    
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
                
                let hasError = jsonResult["error"] != nil
                if hasError {
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