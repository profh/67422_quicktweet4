//
//  ParsedTweet.swift
//  QuickTweet
//
//  Created by Larry Heimann on 10/14/15.
//  Copyright (c) 2015 Larry Heimann. All rights reserved.
//

import UIKit
import Foundation

class ParsedTweet: NSObject {
  var tweetText : String?
  var userName : String?
  var createdAt: String?
  var userAvatarURL : NSURL?
  
  override init () {
    super.init()
  }
  
  
  init (tweetText: String?,
    userName: String?,
    createdAt: String?,
    userAvatarURL : NSURL?) {
      super.init()
      self.tweetText = tweetText
      self.userName = userName
      self.createdAt = createdAt
      self.userAvatarURL = userAvatarURL
  }
  
}