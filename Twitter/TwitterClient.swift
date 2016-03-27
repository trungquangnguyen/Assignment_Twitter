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
let postTweet = "1.1/statuses/update.json"
let favoriteCreate = "1.1/favorites/create.json"
let favoriteDetroy = "1.1/favorites/destroy.json"


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
                    TSMessage.showNotificationWithTitle("Fail getting request Token", type: TSMessageNotificationType.Message)
                    self.loginCompletion?(user: nil, error: error)
            }
        }
    }
    
    func openUrl(url: NSURL) {
        self.fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: { (accessToken: BDBOAuth1Credential!) -> Void in
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
            self.verifyCredentials()
            }) { (error: NSError!) -> Void in
                TSMessage.showNotificationWithTitle("Failed to receive access token", type: TSMessageNotificationType.Message)
        }
    }
    
    func verifyCredentials(){
        self.GET(verifyCredentialsString, parameters: nil, progress: { (progess: NSProgress) -> Void in
            }, success: { (sessionDataTask: NSURLSessionDataTask, respone: AnyObject?) -> Void in
                let user = User(data: respone as! NSDictionary)
                print("Got my access token")
                User.currentUser = user
                print(user.name)
                self.loginCompletion?(user: user,error: nil)
            }) { (sessionDataTask: NSURLSessionDataTask?, error: NSError) -> Void in
                User.currentUser = nil
                self.loginCompletion?(user: nil, error: error)
        }
    }
    
    func homeTimelineWithParams(params: Dictionary<String, String>?, completion: (twitters: [Twitter]!, error: NSError!) -> ()) {
        self.GET(homeTimelineString, parameters: params, progress: { (progess: NSProgress) -> Void in
            
            }, success: { (sectionDataTask: NSURLSessionDataTask, respone: AnyObject?) -> Void in
                let twitters = Twitter.twittersWithArray(respone as! [NSDictionary])
                completion(twitters: twitters, error: nil)
            }) { (sectionDataTask: NSURLSessionDataTask?, error: NSError) -> Void in
                completion(twitters: nil, error: error)
                TSMessage.showNotificationWithTitle("Request Fail", type: TSMessageNotificationType.Message)
        }
        
    }
    func postTweetWithCompletion(text: String, replyId: Int?, completion: (twitter: Twitter!, error: NSError!) -> Void) {
        var params = ["status": text]
        if (replyId != nil) {
            params.updateValue("\(replyId!)", forKey: "in_reply_to_status_id")
        }
        self.POST(postTweet, parameters: params, progress: { (progess: NSProgress) -> Void in
            
            }, success: { (sessionDataTask: NSURLSessionDataTask, response: AnyObject?) -> Void in
                let twitter = Twitter(data: response as! NSDictionary)
                completion(twitter: twitter, error: nil)
            }) { (sessionDataTask: NSURLSessionDataTask?, error: NSError) -> Void in
                completion(twitter: nil,error: error)
                TSMessage.showNotificationWithTitle("PostTweet Fail", type: TSMessageNotificationType.Message)
        }
    }
    
    func toggleFavoriteTweetWithCompletion(twitter: Twitter, completion: (twitter: Twitter!, error: NSError!) -> Void) {
        let params = ["id": twitter.id]
        var url = favoriteCreate
        if (twitter.favorited == true) {
            url = favoriteDetroy
        }
        self.POST(url, parameters: params, progress: { (progess: NSProgress) -> Void in
            }, success: { (sessionTask: NSURLSessionDataTask, response: AnyObject?) -> Void in
                let twitter = Twitter(data: response as! NSDictionary)
                completion(twitter: twitter, error: nil)
            }) { (sessionTask: NSURLSessionDataTask?, error: NSError) -> Void in
                completion(twitter: nil, error: error)
                TSMessage.showNotificationWithTitle("Favorite Fail", type: TSMessageNotificationType.Message)
        }
    }
    func retweetWithCompletion(twitter: Twitter, completion: (twitter: Twitter!, error: NSError!) -> Void) {
        let url = "/1.1/statuses/retweet/\(twitter.id).json"
        self.POST(url, parameters: nil, progress: { (progess: NSProgress) -> Void in
            }, success: { (sessionTask: NSURLSessionDataTask, response: AnyObject?) -> Void in
                let twitter = Twitter(data: response as! NSDictionary)
                completion(twitter: twitter, error: nil)
            }) { (sessionTag: NSURLSessionDataTask?, error: NSError) -> Void in
                TSMessage.showNotificationWithTitle("Reweet Fail!", type: TSMessageNotificationType.Message)
                completion(twitter: nil, error: error)
        }
        
    }
}
