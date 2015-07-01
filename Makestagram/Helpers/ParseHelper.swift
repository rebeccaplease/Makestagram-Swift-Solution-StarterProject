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
    
    static func timelineRequestForCurrentUser(completionBlock: PFArrayResultBlock) {
        
        //retrieve Follow relationships from current user
        let followingQuery = PFQuery(className: "Follow")
        followingQuery.whereKey("fromUser", equalTo:PFUser.currentUser()!)
        
        //retrieve Posts from Follow relationships
        let postsFromFollowedUsers = Post.query()
        postsFromFollowedUsers!.whereKey("user", matchesKey: "toUser", inQuery: followingQuery)
        
        //retrieve posts from this user
        let postsFromThisUser = Post.query()
        postsFromThisUser!.whereKey("user", equalTo: PFUser.currentUser()!)
        
        //combine queryy of two sets of posts (from user and from following users)
        let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
        
        //retrieve user associated with posts (since Post stores a pointer to its user)
        query.includeKey("user")
        
        //sort by date
        query.orderByDescending("createdAt")
        
        //kick off network request
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
}