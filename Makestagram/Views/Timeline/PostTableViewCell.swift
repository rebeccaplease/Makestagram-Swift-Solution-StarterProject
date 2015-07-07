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
    
    var likeBond: Bond<[PFUser]?>!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        likeBond = Bond<[PFUser]?>() { [unowned self] likeList in //not strong reference to self
            //runs when like button is pressed
            //if likeList contains something
            if let likeList = likeList {
                //display usernames
                self.likesLabel.text = self.stringFromUserList(likeList)
                //if user has liked post, highlight likeButton
                self.likeButton.selected = contains(likeList, PFUser.currentUser()!)
                //hide likeIcon if no one likes this post
                self.likesIconImageView.hidden = (likeList.count == 0)
            }
            else {
                self.likesLabel.text = ""
                self.likeButton.selected = false
                self.likesIconImageView.hidden = true
            }
        }
    }
    
    var post: Post? {
        didSet {
            // free memory of image stored with post that is no longer displayed
            // oldValue available in didSet
            if let oldValue = oldValue where oldValue != post {
                // unsubcribe from future updates
                likeBond.unbindAll()
                postImageView.designatedBond.unbindAll()
                // check if unbindings worked. set image to nil to free up memory
                if (oldValue.image.bonds.count == 0) {
                    oldValue.image.value = nil
                }
            }
            
            //optional binding
            if let post = post {
                //bind image of post to postImageView
                post.image ->> postImageView
                //bind likeBond to update image and label
                post.likes ->> likeBond
            }
        }
    }

    //comma delineated list of usernames from an array of users
    func stringFromUserList(userList: [PFUser]) -> String {
        //get usernames
        let usernameList = userList.map { user in user.username! }
        //join array with , as delimiter
        let commaSeparatedUserList = ", ".join(usernameList)
        
        return commaSeparatedUserList
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
