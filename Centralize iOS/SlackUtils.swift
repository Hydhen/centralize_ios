//
//  SlackUtils.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 09/12/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

func getUserNameFromUserObject(message: NSDictionary) -> String {
    let id = message.valueForKey("user") as? String
    
    if (id != nil) {
        for u in current_slack_users {
            let userId = u.valueForKey("id")
            if userId == nil {
                return "Unnamed" // TODO
            } else if userId! as? String == id {
                return u.valueForKey("name")! as! String
            }
        }
    }
    return "Unnamed" // TODO
}

func getUserNameFromUserId(userId: String) -> String {
    for u in current_slack_users {
        let uId = u.valueForKey("id")
        if uId != nil && uId as! String == userId {
            return u.valueForKey("name")! as! String
        }
    }
    return "Unnamed"
}

func getChanNameFromChanId(chanId: String) -> String {
    for c in current_slack_channels {
        let cId = c.valueForKey("id")
        if cId != nil && cId as! String == chanId {
            return c.valueForKey("name")! as! String
        }
    }
    return "Unnamed"
}

func replaceUserName(text: String) -> String {
    let pattern = "<@[^>]*>"
    let matches = matchesForRegexInText(pattern, text: text)
    var ret = text
    for match in matches {
        let userId = matchesForRegexInText("U[^|>]*", text: match)[0]
        let userName = getUserNameFromUserId(userId)
        ret = ret.stringByReplacingOccurrencesOfString(match, withString: String("@" + userName))
    }
    return ret
}

func replaceChannelName(text: String) -> String {
    let pattern = "<#[^>]*>"
    let matches = matchesForRegexInText(pattern, text: text)
    var ret = text
    for match in matches {
        let chanId = matchesForRegexInText("C[^|>]*", text: match)[0]
        let chanName = getChanNameFromChanId(chanId)
        ret = ret.stringByReplacingOccurrencesOfString(match, withString: String("#" + chanName))
    }
    return ret
}
