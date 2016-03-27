//
//  TwitterDetail.swift
//  Twitter
//
//  Created by nguyen trung quang on 3/27/16.
//  Copyright © 2016 trunhquang.com. All rights reserved.
//

import UIKit

class TwitterDetail: UIViewController {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var twitterTextLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var retwitterBtn: UIButton!
    @IBOutlet weak var favoriteBtn: UIButton!
    
    @IBOutlet weak var retwitterCoung: UILabel!
    @IBOutlet weak var favoritesCount: UILabel!
    
    var twitter : Twitter!
    var delegateTwitter :DelegateTwitter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setData(){
        self.faceImage((twitter!.user?.profileImageUrl)!)
        self.nameLbl.text = twitter?.user!.name
        self.usernameLbl.text = twitter!.user!.screenName
        self.twitterTextLbl.text = twitter!.text
        self.timeLbl.text = twitter?.createdAtString
        self.favoriteBtn.selected = twitter!.favorited
        self.retwitterBtn.selected = (twitter?.retweeted)!
        retwitterCoung.text = "\(twitter!.retweetCount)"
        favoritesCount.text = "\(twitter!.favoritesCount)"
    }
    func faceImage(url: NSURL){
        let imageRequest = NSURLRequest(URL: url)
        self.profileImage.setImageWithURLRequest(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                if imageResponse != nil {
                    self.profileImage.alpha = 0.0
                    self.profileImage.image = image
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.profileImage.alpha = 1.0
                    })
                } else {
                    self.profileImage.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
        })
    }
    
    @IBAction func onReply(sender: AnyObject) {
        self.performSegueWithIdentifier("replyTweetFromDetails", sender: self)
    }

    @IBAction func onRetwitter(sender: AnyObject) {

        retwitterBtn.selected = !self.twitter.retweeted
        if (!self.twitter.retweeted) {
            TwitterClient.sharedInstance.retweetWithCompletion(self.twitter, completion: { (tweet, error) -> Void in
                if (tweet != nil) {
                    self.twitter!.retweeted = tweet.retweeted
                    self.twitter.retweetCount = tweet.retweetCount
                    self.retwitterBtn.selected = tweet.retweeted
                } else {
                    self.retwitterBtn.selected = self.twitter.retweeted
                }
                
            })
        }
    }

    @IBAction func onFavorites(sender: AnyObject) {
        favoriteBtn.selected = !self.twitter.favorited
        TwitterClient.sharedInstance.toggleFavoriteTweetWithCompletion(twitter,
            completion: { (tweet, error) -> Void in
                if (tweet != nil) {
                    self.twitter.favorited = tweet.favorited
                    self.twitter.favoritesCount = tweet.favoritesCount
                } else {
                    self.favoriteBtn.selected = self.twitter.favorited
                }
            }
        )

    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let tweet = segue.destinationViewController as! Tweet
        tweet.twitter = twitter
        tweet.delegateTweet = self
    }
}

extension TwitterDetail: DelegateTwitter{
    func addTwitter(twitter: Twitter){
        self.delegateTwitter.addTwitter(twitter)
    }
    func updatetwitter(twitter: Twitter){
        
    }
}
