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
    
    static func timelineRequestForCurrentUser(range: Range<Int>, completionBlock: PFArrayResultBlock) {
        
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
        
        
        query.skip = range.startIndex
        //load this chunk
        query.limit = range.endIndex - range.startIndex
        
        //kick off network request
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    //MARK: Liking
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
    
    //MARK: Following
    /**
    Fetches all users that the provided user is following.
    
    :param: user The user whose followees you want to retrieve
    :param: completionBlock The completion block that is called when the query completes
    */
    static func getFollowingUsersForUser(user: PFUser, completionBlock: PFArrayResultBlock) {
        let query = PFQuery(className: ParseFollowClass)
        
        query.whereKey(ParseFollowFromUser, equalTo: user)
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    /**
    Establishes a follow relationship between two users.
    
    :param: user    The user that is following
    :param: toUser  The user that is being followed
    */
    static func addFollowRelationshipFromUser(user: PFUser, toUser: PFUser) {
        let followObject = PFObject(className: ParseFollowClass)
        
        followObject.setObject(user, forKey: ParseFollowFromUser)
        followObject.setObject(toUser, forKey: ParseFollowToUser)
        
        followObject.saveInBackgroundWithBlock(nil)
    }
    /**
    Deletes a follow relationship between two users.
    
    :param: user    The user that is following
    :param: toUser  The user that is being followed
    */
    static func removeFollowRelationship(user: PFUser, toUser: PFUser) {
        let query = PFQuery(className: ParseFollowClass)
        
        query.whereKey(ParseFollowFromUser, equalTo: user)
        query.whereKey(ParseFollowToUser, equalTo: toUser)
        
        query.findObjectsInBackgroundWithBlock { (results: [AnyObject]?, error: NSError?) -> Void in
            //optional binding
            if let results = results as? [PFObject] {
                //iterate through results (in case more than one..)
                for follow in results  {
                    follow.deleteInBackgroundWithBlock(nil)
                }
            }
        }
    }
    //MARK: Users
    /**
    Fetch all users, except the one that's currently signed in.
    Limits the amount of users returned to 20.
    
    :param: completionBlock The completion block that is called when the query completes
    
    :returns: The generated PFQuery
    */
    static func allUsers(completionBlock: PFArrayResultBlock) -> PFQuery {
        let query = PFUser.query()!
        //exclude current user
        query.whereKey(ParseHelper.ParseUserUsername, notEqualTo: PFUser.currentUser()!.username!)
        
        query.orderByAscending(ParseHelper.ParseUserUsername)
        query.limit = 20
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
        
        return query
    }
    
    /**
    Fetch users whose usernames match the provided search term.
    
    :param: searchText The text that should be used to search for users
    :param: completionBlock The completion block that is called when the query completes
    
    :returns: The generated PFQuery
    */
    static func searchUsers(searchText: String, completionBlock: PFArrayResultBlock) -> PFQuery {
        /*
        NOTE: We are using a Regex to allow for a case insensitive compare of usernames.
        Regex can be slow on large datasets. For large amount of data it's better to store
        lowercased username in a separate column and perform a regular string compare.
        */
        let query = PFUser.query()!.whereKey(ParseHelper.ParseUserUsername,
            matchesRegex: searchText, modifiers: "i")
        
        //exclude current user
        query.whereKey(ParseHelper.ParseUserUsername,
            notEqualTo: PFUser.currentUser()!.username!)
        
        //sort usernames
        query.orderByAscending(ParseHelper.ParseUserUsername)
        query.limit = 20
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
        
        return query
    }
}

extension PFObject : Equatable {
    
}
//redefine equality to refer to same object id (not same object. because the current user can be rep by diff objects
public func ==(lhs: PFObject, rhs: PFObject) -> Bool {
    return lhs.objectId == rhs.objectId
}