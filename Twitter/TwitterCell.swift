//
//  TwitterCell.swift
//  Twitter
//
//  Created by nguyen trung quang on 3/27/16.
//  Copyright © 2016 trunhquang.com. All rights reserved.
//

import UIKit


class TwitterCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var twitterTextLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var retwitterBtn: UIButton!
    @IBOutlet weak var favoriteBtn: UIButton!
    
    var index: Int!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    var twitter: Twitter?{
        didSet{
            replyBtn.tag = index
            retwitterBtn.tag = index
            favoriteBtn.tag = index
            faceImage((twitter?.user?.profileImageUrl)!)
            nameLbl.text = twitter?.user!.name
            usernameLbl.text = twitter!.user!.screenName
            twitterTextLbl.text = twitter!.text
            timeLbl.text = twitter?.createdAt?.shortTimeAgoSinceNow()
            favoriteBtn.selected = twitter!.favorited
            retwitterBtn.selected = (twitter?.retweeted)!
        }
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

}
