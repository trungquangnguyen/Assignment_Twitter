//
//  Tweet.swift
//  Twitter
//
//  Created by nguyen trung quang on 3/27/16.
//  Copyright © 2016 trunhquang.com. All rights reserved.
//

import UIKit

class Tweet: UIViewController {
    var twitter: Twitter!
 
    @IBOutlet weak var lblUser: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var textView: UITextView!

    var delegateTweet: DelegateTwitter!
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setData(){
        let user = User.currentUser
        self.faceImage((user?.profileImageUrl)!)
        self.lblName.text = user!.name
        self.lblUser.text = "@\(user!.screenName)"
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
    @IBAction func postTweet(sender: AnyObject) {
        var text = self.textView.text
        if (self.twitter != nil) {
            text = "@\(self.twitter.user!.screenName! ) \(text)"
        }
        TwitterClient.sharedInstance.postTweetWithCompletion(text, replyId: self.twitter?.id ?? nil) { (twitter, error) -> Void in
            if (twitter != nil) {
                self.delegateTweet.addTwitter(twitter)
                self.navigationController?.popToRootViewControllerAnimated(true)
            } else {
                print(error)
            }
        }
    }
}
