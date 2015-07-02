//
//  PostTableViewCell.swift
//  Makestagram
//
//  Created by Rebecca Poch on 7/1/15.
//  Copyright (c) 2015 Rebecca Poch. All rights reserved.
//

import UIKit
import Bond
import Parse

class PostTableViewCell: UITableViewCell {
 
     //UI view
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var likesIconImageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
   
    var post: Post? {
        didSet {
            //optional binding
            if let post = post {
                //bind image of post to postImageView
                post.image ->> postImageView
            }
        }
    }
    
    @IBAction func moreButtonTapped(sender: AnyObject) {
        
    }
    @IBAction func likeButtonTapped (sender: AnyObject) {
        post?.toggleLikePost(PFUser.currentUser()!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
