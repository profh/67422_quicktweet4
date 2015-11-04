//
//  ParsedTweetCell.swift
//  QuickTweet
//
//  Created by Larry Heimann on 10/14/15.
//  Copyright (c) 2015 Larry Heimann. All rights reserved.
//

import Foundation
import UIKit

class ParsedTweetCell: UITableViewCell {
  
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var tweetTextLabel: UILabel!
  @IBOutlet weak var createdAtLabel: UILabel!
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}