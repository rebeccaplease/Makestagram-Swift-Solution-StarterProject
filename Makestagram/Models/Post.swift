//
//  File.swift
//  Makestagram
//
//  Created by Rebecca Poch on 6/30/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import Parse
import UIKit
import Bond
import ConvenienceKit

class Post : PFObject, PFSubclassing { //custom PFObject, inherit form PFSubclassing to conform to protocol
    
    //define each property that you want to access inside Post
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    var image: Dynamic<UIImage?> = Dynamic(nil)
    var likes: Dynamic<[PFUser]?> = Dynamic(nil) //nil before DL
    var photoUploadTask: UIBackgroundTaskIdentifier?
    
    static var imageCache: NSCacheSwift<String, UIImage>!
    
    //MARK: PFSubclassing Protocol
    //connect parse class and swift class
    static func parseClassName() -> String {
        return "Post"
    }
    
    //init and initialize: boilerplate code
    override init() {
        super.init()
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
            // empty cache
            Post.imageCache = NSCacheSwift<String, UIImage>()
        }
    }
    
    //MARK: Post methods
    func uploadPost() {
        //get reference to image
        let imageData = UIImageJPEGRepresentation(image.value, 0.8) //turn UI image into image data, then image file
        let imageFile = PFFile(data: imageData)
        
        //finish uploading in alloted time if app is closed
        photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
        }
        
        //end task after save (completion handler)
        imageFile.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
        }
        
        //associate post with current user
        user = PFUser.currentUser()
        //store image in parse
        self.imageFile = imageFile
        saveInBackgroundWithBlock(nil)
    }
    
    func downloadImage() {
        //assign from cache if possible
        image.value = Post.imageCache[self.imageFile!.name]
        //if not already downloaded, download image
        if (image.value == nil) {
            //start DL in background
            imageFile?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                if let data = data {
                    let image = UIImage(data: data, scale: 1.0)!
                    //assign downloaded image to image in post
                    self.image.value = image
                    //store in cache
                    Post.imageCache[self.imageFile!.name] = image
                }
            }
        }
    }
    
    func fetchLikes() {
        //if likes already has values dont retrieve likes
        if(likes.value != nil) {
            return
        }
        //get likes for this post
        ParseHelper.likesForPosts(self, completionBlock: { (var likes: [AnyObject]?, error: NSError?) -> Void in
            
            //filter out users that don't exist anymore
            likes = likes?.filter { like in like[ParseHelper.ParseLikeFromUser] != nil
            }
            //get the users associated with each like
            self.likes.value = likes?.map {like in
                let like = like as! PFObject
                let fromUser = like[ParseHelper.ParseLikeFromUser] as! PFUser
                return  fromUser
            }
        })
    }
    
    func doesUserLikePost(user: PFUser) -> Bool {
        if let likes = likes.value {
            return contains(likes, user) //is user in likes?
        }
        else {
            return false
        }
    }
    
    func toggleLikePost(user: PFUser) {
        //if post already liked, remove from likes, update parse
        if(doesUserLikePost(user)) {
            likes.value = likes.value?.filter {$0 != user }
            ParseHelper.unlikePost(user, post: self)
        }
        //else add to cache, update parse
        else {
            likes.value?.append(user)
            ParseHelper.likePost(user, post: self)
        }
    }
}
