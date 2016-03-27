//
//  Twitter.swift
//  Twitter
//
//  Created by nguyen trung quang on 3/26/16.
//  Copyright © 2016 trunhquang.com. All rights reserved.
//

import UIKit

class Twitter: NSObject {
    var id: Int
    var user: User?
    var text: String?
    var createdAt: NSDate?
    var createdAtString: String?
    var favoritesCount: Int
    var favorited: Bool
    var retweetCount: Int
    var retweeted: Bool
    var isRetweet = false
    var embeddedTwitted: Twitter!
    
    init(data: NSDictionary) {
        self.id = data["id"] as! Int!
        user = User(data: data["user"] as! NSDictionary)
        text = data["text"] as! String!
        createdAtString = data["created_at"] as! String!
        self.favoritesCount = data["favorite_count"] as! Int!
        self.favorited = data["favorited"] as! Bool
        self.retweetCount = data["retweet_count"] as! Int!
        self.retweeted = data["retweeted"] as! Bool
        if (data["retweeted_status"] != nil) {
            self.isRetweet = true
            self.embeddedTwitted = Twitter(data: data["retweeted_status"] as! NSDictionary)
        }
        // warningformat day same region*/
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        self.createdAt = formatter.dateFromString(self.createdAtString!)
        formatter.dateFormat = "MMM d hh:mm a"
        self.createdAtString = formatter.stringFromDate(self.createdAt!)
    }
    
    class func twittersWithArray(array: [NSDictionary]) -> [Twitter] {
        var twitters = [Twitter]()
        for data in array {
            twitters.append(Twitter(data: data))
        }
        return twitters
    }
}
