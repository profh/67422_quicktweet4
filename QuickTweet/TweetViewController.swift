//
//  ViewController.swift
//  QuickTweet
//
//  Created by Larry Heimann on 10/11/15.
//  Copyright (c) 2015 Larry Heimann. All rights reserved.
//

import UIKit
import Social
import Accounts

class TweetViewController: UITableViewController {
  
  var parsedTweets : [ParsedTweet] = []
  let defaultAvatarURL = NSURL(string: "https://abs.twimg.com/sticky/default_profile_images/default_profile_6_200x200.png")

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.rowHeight = 125
    reloadTweets()
    var refresher = UIRefreshControl()
    refresher.addTarget(self,
      action: "handleRefresh:",
      forControlEvents: UIControlEvents.ValueChanged)
    refreshControl = refresher
    
    // adding a toolbar, but in code rather than storyboard
    let compose = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "sendTweet")
    let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
    let refresh = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "reloadTweets")
    // let viewAll = UIBarButtonItem(title: "View All", style: .Plain, target: self, action: "viewTweets")
    toolbarItems = [compose, spacer, refresh]
    navigationController?.toolbarHidden = false  // see option in storyboard for this to contrast
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // methods associated with toolbar items
  func sendTweet() {
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
      let tweetVC = SLComposeViewController (forServiceType: SLServiceTypeTwitter)
      tweetVC.setInitialText("Testing a twitter app for 67-442")
      self.presentViewController(tweetVC, animated: true, completion: nil)
    } else {
      println ("Can't send tweet")
    }
  }
  
  func reloadTweets() {
    // tableView.reloadData()
    let accountStore = ACAccountStore()
    let twitterAccountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
    accountStore.requestAccessToAccountsWithType(twitterAccountType,
      options: nil,
      completion: {
        (granted: Bool, error: NSError!) -> Void in
        if (!granted) {
          println ("account access not granted")
        } else {
          let twitterAccounts = accountStore.accountsWithAccountType(twitterAccountType)
          if twitterAccounts.count == 0 {
            println ("no twitter accounts configured")
            return
          } else {
            let twitterParams = ["count" : "100"]
            let twitterAPIURL = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
            let request = SLRequest(
              forServiceType: SLServiceTypeTwitter,
              requestMethod:SLRequestMethod.GET,
              URL:twitterAPIURL,
              parameters:twitterParams)
            request.account = twitterAccounts.first as! ACAccount
            request.performRequestWithHandler ( {
              (data: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) -> Void in
              self.handleTwitterData(data, urlResponse: urlResponse, error: error)
            })
          }
        }
    })
  }
  
  func handleTwitterData (data: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) {
      if let dataValue = data {
        var parseError : NSError? = nil
        let jsonObject : AnyObject? =
          NSJSONSerialization.JSONObjectWithData(
            dataValue,
            options: NSJSONReadingOptions(0),
            error: &parseError)
        if parseError != nil {
          return
        }
        if let jsonArray = jsonObject as? [ [String:AnyObject] ] {
          // println(jsonArray)
          self.parsedTweets.removeAll(keepCapacity: true)
          for tweetDict in jsonArray {
            let parsedTweet = ParsedTweet()
            parsedTweet.tweetText = tweetDict["text"] as? String
            parsedTweet.createdAt = tweetDict["created_at"] as? String
            let userDict = tweetDict["user"] as! NSDictionary
            parsedTweet.userName = userDict["name"] as? String
            parsedTweet.userAvatarURL = NSURL (string:
              userDict ["profile_image_url"] as! String)
            self.parsedTweets.append(parsedTweet)
          }
          dispatch_async(dispatch_get_main_queue(),
            {
              self.tableView.reloadData()
          })
        }
      } else {
        println ("handleTwitterData received no data")
      }
  }
  
  // dealing with the tableView
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
      return parsedTweets.count
  }
  
  override func tableView (_tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier("CustomTweetCell") as! ParsedTweetCell
      let parsedTweet = parsedTweets[indexPath.row]
      cell.userNameLabel.text = parsedTweet.userName
      cell.tweetTextLabel.text = parsedTweet.tweetText
      cell.createdAtLabel.text = parsedTweet.createdAt
      if parsedTweet.userAvatarURL != nil {
        cell.avatarImageView.image = nil
        dispatch_async(dispatch_get_global_queue(
          QOS_CLASS_DEFAULT, 0),
          {
            if let imageData = NSData (contentsOfURL: parsedTweet.userAvatarURL!) {
                let avatarImage = UIImage(data: imageData)
                dispatch_async(dispatch_get_main_queue(),
                  {
                    if cell.userNameLabel.text == parsedTweet.userName {
                      cell.avatarImageView.image = avatarImage
                    } else {
                      println ("avatar mismatch, my bad")
                    }
                })
            }
        })
        
      }
      return cell
  }
  
  @IBAction func handleRefresh (sender : AnyObject?) {
    reloadTweets()
    refreshControl!.endRefreshing()
  }

}

