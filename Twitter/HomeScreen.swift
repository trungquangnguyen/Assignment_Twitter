//
//  HomeScreen.swift
//  Twitter
//
//  Created by nguyen trung quang on 3/26/16.
//  Copyright © 2016 trunhquang.com. All rights reserved.
//

import UIKit

class HomeScreen: UIViewController {
    @IBOutlet weak var tbvHome: UITableView!
    
    var refreshControl :UIRefreshControl!
    var twitters : [Twitter]?
    var lastTwitterID = 0
    var loadMore = false
    var loadMoreView : InfiniteScrollActivityView!

    
    let tweetsCount = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbvHome.estimatedRowHeight = 100
        tbvHome.rowHeight = UITableViewAutomaticDimension
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, 0, 80, 80)
        loadMoreView = InfiniteScrollActivityView(frame: frame)
        loadMoreView!.hidden = true
        tbvHome.tableFooterView = loadMoreView
        setRefreshControl()
        MBProgressHUD.showHUDAddedTo(tbvHome, animated: true)
        homeTimeline()
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
// MARK: - privateMethod
    func showMessage(error: NSError){
        print("err")
    }
    func setRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.blueColor()
        refreshControl.alpha = 0.5
        refreshControl.addTarget(self, action: Selector("homeTimeline"), forControlEvents: UIControlEvents.ValueChanged)
        tbvHome.insertSubview(refreshControl, atIndex: 0)
    }

    func homeTimeline(){
        var params = Dictionary<String,String>()
        params["count"] = "\(tweetsCount)"
        TwitterClient.sharedInstance.homeTimelineWithParams(params) { (twitters, error) -> () in
            if error  != nil {
                self.showMessage(error)
            }else{
                if (twitters.count > 0) {
                    self.lastTwitterID = twitters.last!.id
                }
                self.twitters = twitters
                self.tbvHome.reloadData()
            }
            self.refreshControl.endRefreshing()
            MBProgressHUD.hideHUDForView(self.tbvHome, animated: true)
            self.loadMoreView!.stopAnimating()
            self.loadMore = false
        }
    }
    
    func loadMoreTweets() {
        var params = Dictionary<String,String>()
        params["count"] = "\(tweetsCount)"
        if (self.lastTwitterID != 0) {
            params["max_id"] = "\(self.lastTwitterID)"
        }
        TwitterClient.sharedInstance.homeTimelineWithParams(params) { (twitters, error) -> () in
            if (error == nil) {
                self.refreshControl.endRefreshing()
                for twitter in twitters {
                    let row = self.twitters!.count
                    self.twitters!.append(twitter)
                    self.tbvHome.insertRowsAtIndexPaths([NSIndexPath(forRow:row, inSection:0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
                let lastTwitter = twitters.last
                if (lastTwitter != nil) {
                    self.lastTwitterID = lastTwitter!.id
                }
                self.loadMoreView!.stopAnimating()
                self.loadMore = false
            }
        }
    }
    
    @IBAction func onLogout(sender: AnyObject) {
        User.currentUser?.logout()
    }

}
// MARK: - ExtensionTableView
extension HomeScreen: UITableViewDelegate, UITableViewDataSource{
    //tableViewDatasource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return twitters?.count ?? 0
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TwitterCell") as! TwitterCell
        cell.twitter = twitters![indexPath.row]
        return cell
    }
    //tableViewDelegate
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView .deselectRowAtIndexPath(indexPath, animated: true)
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row + 5 >= twitters!.count && !self.loadMore) {
             self.loadMore = true
            self.loadMoreView.startAnimating()
            loadMoreTweets()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
