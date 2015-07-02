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

class Post : PFObject, PFSubclassing { //custom PFObject, inherit form PFSubclassing to conform to protocol
    
    //define each property that you want to access inside Post
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    var image: Dynamic<UIImage?> = Dynamic(nil)
    var photoUploadTask: UIBackgroundTaskIdentifier?
    
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
        var onceToken : dispatch_once_t = 0
        dispatch_once(&onceToken) {
            //inform parse about this subclass
            self.registerSubclass()
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
        //if not already downloaded, download image
        if (image.value == nil) {
            //start DL in background
            imageFile?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                if let data = data {
                    let image = UIImage(data: data, scale: 1.0)!
                    //assign downloaded image to image in post
                    self.image.value = image
                }
            }
        }
    }
    
}