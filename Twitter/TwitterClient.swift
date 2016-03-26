//
//  TwitterClient.swift
//  Twitter
//
//  Created by nguyen trung quang on 3/26/16.
//  Copyright © 2016 trunhquang.com. All rights reserved.
//
import Foundation

let consumerKey = "XLJhSDnAO1vL0v5DSZbF2WwCk"
let consumerSecret = "XuS2R9RVx8TVZh5t0g4mP7JwM53kxert8FdekZhWOnBubtTQHg"
let twitterBaseUrl = "https://api.twitter.com"
let twitterOauthUrl = "https://api.twitter.com/oauth/authorize?oauth_token="
let verifyCredentialsString = "1.1/account/verify_credentials.json"
let homeTimelineString = "1.1/statuses/home_timeline.json"



class TwitterClient: BDBOAuth1SessionManager {
    
    var loginCompletion: ((user: User?, error: NSError?) -> ())?
    
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: NSURL(string: twitterBaseUrl), consumerKey: consumerKey, consumerSecret: consumerSecret)
            
        }
        return Static.instance
    }
    
    func logInWithComplete(complete: (user: User?, error: NSError?) -> ()) {
        loginCompletion = complete
        if User.currentUser != nil {
            self.loginCompletion?(user: User.currentUser, error: nil)
        }else{
            self.requestSerializer.removeAccessToken()
            self.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "RickClient://oauth"), scope: nil , success: { (requestTocken: BDBOAuth1Credential!) -> Void in
                let oauthUrl = requestTocken.token
                UIApplication.sharedApplication().openURL(NSURL(string: twitterOauthUrl + oauthUrl)!)
                }) { (error: NSError!) -> Void in
                    print("Fail getting request Token")
                    self.loginCompletion?(user: nil, error: error)
            }
        }
    }
    
    func openUrl(url: NSURL) {
        self.fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: { (accessToken: BDBOAuth1Credential!) -> Void in
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
            self.verifyCredentials()
            print("Got my access token")
            }) { (error: NSError!) -> Void in
                print("Failed to receive access token")
        }
    }
    
    func verifyCredentials(){
        self.GET(verifyCredentialsString, parameters: nil, progress: { (progess: NSProgress) -> Void in
            }, success: { (sessionDataTask: NSURLSessionDataTask, respone: AnyObject?) -> Void in
                let user = User(data: respone as! NSDictionary)
                User.currentUser = user
                print(user.name)
                self.loginCompletion?(user: user,error: nil)
            }) { (sessionDataTask: NSURLSessionDataTask?, error: NSError) -> Void in
                print("Fail verifyCredentials")
                self.loginCompletion?(user: nil, error: error)
        }
    }
    
    func homeTimelineWithParams(params: Dictionary<String, String>?, completion: (tweets: [Twitter]!, error: NSError!) -> ()) {
        self.GET(homeTimelineString, parameters: params, progress: { (progess: NSProgress) -> Void in
            
            }, success: { (sectionDataTask: NSURLSessionDataTask, respone: AnyObject?) -> Void in
                let twitters = Twitter.tweetsWithArray(respone as! [NSDictionary])
                completion(tweets: twitters, error: nil)
            }) { (sectionDataTask: NSURLSessionDataTask?, error: NSError) -> Void in
                 completion(tweets: nil, error: error)
        }
        
    }
    
}
