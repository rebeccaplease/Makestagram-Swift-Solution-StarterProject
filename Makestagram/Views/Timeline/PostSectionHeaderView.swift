//
//  PostSectionHeaderView.swift
//  Makestagram
//
//  Created by Rebecca Poch on 7/8/15.
//  Copyright (c) 2015 Rebecca Poch. All rights reserved.
//

import UIKit

class PostSectionHeaderView: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var postTimeLabel: UILabel!
    
    var post: Post? {
        didSet {
            if let post = post {
                usernameLabel.text = post.user?.username
                
                postTimeLabel.text = post.createdAt?.shortTimeAgoSinceDate(NSDate()) ?? ""
            }
        }
    }
    

}
