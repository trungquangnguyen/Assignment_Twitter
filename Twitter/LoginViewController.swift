//
//  ViewController.swift
//  Twitter
//
//  Created by nguyen trung quang on 3/25/16.
//  Copyright © 2016 trunhquang.com. All rights reserved.
//

import UIKit
class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK - private Action/method
    
    @IBAction func onSignIn(sender: UIButton) {
        TwitterClient.sharedInstance.logInWithComplete { (user, error) -> () in
            if user != nil {
                self.performSegueWithIdentifier("loggedInSegue", sender: self)
            }
        }
    }

}

