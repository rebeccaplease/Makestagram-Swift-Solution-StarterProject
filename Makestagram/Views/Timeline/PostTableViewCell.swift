//
//  PostTableViewCell.swift
//  Makestagram
//
//  Created by Rebecca Poch on 7/1/15.
//  Copyright (c) 2015 Rebecca Poch. All rights reserved.
//

import UIKit
import Bond

class PostTableViewCell: UITableViewCell {
 
    @IBOutlet weak var postImageView: UIImageView!
    
    var post: Post? {
        didSet {
            //optional binding check
            if let post = post {
                //binding (post.image has to be dynamic)
                post.image ->> postImageView
            }
        }
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
