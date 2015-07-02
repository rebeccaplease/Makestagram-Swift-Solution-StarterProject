//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Rebecca Poch on 6/29/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse



class TimelineViewController: UIViewController {

    var photoTakingHelper: PhotoTakingHelper?
    var posts: [Post] = []
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidAppear(animated: Bool) {
    
        super.viewDidAppear(animated)

        // Do any additional setup after loading the view.
        self.tabBarController?.delegate = self //since timeline is the first view that is loaded, put delegate in here
        
        ParseHelper.timelineRequestForCurrentUser { (result: [AnyObject]?, error: NSError?) -> Void in  //completion block
            
            //return AnyObject array and cast into Post array(if fail, store into empty array)
            self.posts = result as? [Post] ?? [] //nil coalescing operator
            
            //refresh table view
            self.tableView.reloadData()
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

extension TimelineViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    //called right before table view is about to present a cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
            
        let post = posts[indexPath.row]
        //start DL before post display
        post.downloadImage()
        post.fetchLikes()
        //assign post to this cell
        cell.post = post
        
        return cell
    }
}