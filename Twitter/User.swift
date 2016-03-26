//
//  User.swift
//  Twitter
//
//  Created by nguyen trung quang on 3/26/16.
//  Copyright © 2016 trunhquang.com. All rights reserved.
//

import UIKit

var _currentUser: User?
var currentUserKey = "currentUser"
var userDidLoginNotification = "userDidLoginNotification"
var userDidLogoutNotification = "userDidLogoutNotification"

class User: NSObject {
    var name: String!
    var screenName: String!
    var profileImageUrl: NSURL!
    var tagLine: String!
    var data: NSDictionary!
    
    
    init(data: NSDictionary) {
        self.data = data
        name = data["name"] as! String
        screenName = data["screen_name"] as! String
        profileImageUrl = NSURL(string: data["profile_image_url"] as! String)
        tagLine = data["description"] as! String
    }
    
    class var currentUser: User? {
        get {
            if (_currentUser == nil) {
                let data = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData
                if (data != nil) {
                    do {
                        let jsonResults = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                        _currentUser  = User(data: jsonResults as! NSDictionary)
                    } catch {
                    }
                }
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user
            if (_currentUser != nil) {
                do {
                    let data = try NSJSONSerialization.dataWithJSONObject(user!.data, options: [])
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey)
                } catch {
                }
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func logout() {
        User.currentUser = nil
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: userDidLogoutNotification, object: nil))
    }
    class func loginWithComplete(complete:()->()) {
        TwitterClient.sharedInstance.logInWithComplete { (user, error) -> () in
            if user != nil {
                complete()
            }
        }
    }
}
