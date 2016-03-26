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


class TwitterClient: BDBOAuth1SessionManager {

    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: NSURL(string: twitterBaseUrl), consumerKey: consumerKey, consumerSecret: consumerSecret)
            
        }
        return Static.instance
    }
    
    func logIn(){
        self.requestSerializer.removeAccessToken()
        self.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "RickClient://oauth"), scope: nil , success: { (requestTocken: BDBOAuth1Credential!) -> Void in
            print("got the request Token")
            let oauthUrl = requestTocken.token
            UIApplication.sharedApplication().openURL(NSURL(string: twitterOauthUrl + oauthUrl)!)
            }) { (error: NSError!) -> Void in
                print("Fail getting request Token")
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
    
    //MARK - private method
    func verifyCredentials(){
        self.GET(verifyCredentialsString, parameters: nil, progress: { (progess: NSProgress) -> Void in
            
            }, success: { (sessionDataTask: NSURLSessionDataTask, respone: AnyObject?) -> Void in
                print(respone!)
            }) { (sessionDataTask: NSURLSessionDataTask?, error: NSError) -> Void in
                print("Fail verifyCredentials")
        }
    }
    
}
