//
//  ParseHelper.swift
//  Makestagram
//
//  Created by Rebecca Poch on 7/1/15.
//  Copyright (c) 2015 Rebecca Poch. All rights reserved.
//

import Foundation
import Parse

class ParseHelper {
    
    // Following Relation
    static let ParseFollowClass       = "Follow"
    static let ParseFollowFromUser    = "fromUser"
    static let ParseFollowToUser      = "toUser"
    
    // Like Relation
    static let ParseLikeClass         = "Like"
    static let ParseLikeToPost        = "toPost"
    static let ParseLikeFromUser      = "fromUser"
    
    // Post Relation
    static let ParsePostUser          = "user"
    static let ParsePostCreatedAt     = "createdAt"
    
    // Flagged Content Relation
    static let ParseFlaggedContentClass    = "FlaggedContent"
    static let ParseFlaggedContentFromUser = "fromUser"
    static let ParseFlaggedContentToPost   = "toPost"
    
    // User Relation
    static let ParseUserUsername      = "username"
    
    static func timelineRequestForCurrentUser(completionBlock: PFArrayResultBlock) {
        
        //retrieve Follow relationships from current user
        let followingQuery = PFQuery(className: ParseFollowClass)
        followingQuery.whereKey(ParseFollowFromUser, equalTo:PFUser.currentUser()!)
        
        //retrieve Posts from Follow relationships
        let postsFromFollowedUsers = Post.query()
        postsFromFollowedUsers!.whereKey(ParsePostUser, matchesKey: ParseFollowToUser, inQuery: followingQuery)
        
        //retrieve posts from this user
        let postsFromThisUser = Post.query()
        postsFromThisUser!.whereKey(ParsePostUser, equalTo: PFUser.currentUser()!)
        
        //combine queryy of two sets of posts (from user and from following users)
        let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
        
        //retrieve user associated with posts (since Post stores a pointer to its user)
        query.includeKey(ParsePostUser)
        
        //sort by date
        query.orderByDescending(ParsePostCreatedAt)
        
        //kick off network request
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    static func likePost(user: PFUser, post: Post) {
        
        let likeObject = PFObject(className: ParseLikeClass)
        likeObject[ParseLikeFromUser] = user
        likeObject[ParseLikeToPost] = post
        
        likeObject.saveInBackgroundWithBlock(nil)
    }
    
    static func unlikePost(user: PFUser, post: Post) {
        //retrieve all Likes
        let query = PFQuery(className: ParseLikeClass)
        //retrieve all user's likes
        query.whereKey(ParseLikeFromUser, equalTo: user)
        //retrieve post to unlike
        query.whereKey(ParseLikeToPost, equalTo: post)
        
        query.findObjectsInBackgroundWithBlock { (results: [AnyObject]?, error: NSError?) -> Void in
            //optional binding
            if let results = results as? [PFObject] {
                //iterate through results (in case more than one..)
                for likes in results  {
                    likes.deleteInBackgroundWithBlock(nil)
                }
            }
        }
    }
    static func likesForPosts(post: Post, completionBlock: PFArrayResultBlock) {
        //retrieve all Likes
        let query = PFQuery(className: ParseLikeClass)
        //retrieve post of interest
        query.whereKey(ParseLikeToPost, equalTo: post)
        //include user of each like (to display). could do separately
        query.includeKey(ParseLikeFromUser)
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
}

extension PFObject : Equatable {
    
}
//redefine equality to refer to same object id (not same object. because the current user can be rep by diff objects
public func ==(lhs: PFObject, rhs: PFObject) -> Bool {
    return lhs.objectId == rhs.objectId
}