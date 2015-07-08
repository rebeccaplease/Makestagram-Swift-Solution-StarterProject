//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Rebecca Poch on 6/29/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse
import ConvenienceKit


class TimelineViewController: UIViewController, TimelineComponentTarget {
    
    var photoTakingHelper: PhotoTakingHelper?
    
    //handles saving posts
    var timelineComponent: TimelineComponent<Post, TimelineViewController>!
    
    let defaultRange = 0...4
    let additionalRangeSize = 5
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timelineComponent = TimelineComponent(target: self)
        
        self.tabBarController?.delegate = self //since timeline is the first view that is loaded, put delegate in here
    }
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
      timelineComponent.loadInitialIfRequired()
        
        //loadInRange(defaultRange) { <#([Post]?) -> Void##([Post]?) -> Void#>)  -> Void in
        
        
    }
    
    func loadInRange(range: Range<Int>, completionBlock: ([Post]?) -> Void) {
        
        ParseHelper.timelineRequestForCurrentUser(range) { (result: [AnyObject]?, error: NSError?) -> Void in  //completion block
            
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
            }
            //return AnyObject array and cast into Post array(if fail, store into empty array)
            let posts = result as? [Post] ?? [] //nil coalescing operator
            
            completionBlock(posts)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    func takePhoto() {
        // instantiate photo taking class, provide callback when photo is selected
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!) { (image: UIImage?) in //trailing closure
            println("Received a callback")
            
            let post = Post()
            post.image.value = image!
            post.uploadPost()
        }
    }
}

//MARK: Tab Bar Delegate
extension TimelineViewController: UITabBarControllerDelegate {
    
    func tabBarController (tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if (viewController is PhotoViewController) {
            takePhoto()
            return false //don't select photo view controller, take photo instead
        }
        else {
            return true // for other view controllers, just select them
        }
    }
}

extension TimelineViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        timelineComponent.targetWillDisplayEntry(indexPath.row)
    }
}

extension TimelineViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timelineComponent.content.count
    }
    
    //called right before table view is about to present a cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
        
        let post = timelineComponent.content[indexPath.row]
        //start DL before post display
        post.downloadImage()
        post.fetchLikes()
        //assign post to this cell
        cell.post = post
        
        return cell
    }
}

