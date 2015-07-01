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
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tabBarController?.delegate = self //since timeline is the first view that is loaded, put delegate in here
        
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
        query.findObjectsInBackgroundWithBlock { (result: [AnyObject]?, error: NSError?) -> Void in  //completion block
            
            //return AnyObject array and cast into Post array(if fail, store into empty array)
            self.posts = result as? [Post] ?? [] //nil coalescing operator
            
            //loop through and assign image to post
            for post in self.posts {
                let data = post.imageFile?.getData()
                post.image = UIImage(data: data!, scale: 1.0)
            }
            
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
            post.image = image
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
            
        //cell.textLabel!.text = "Post"
        cell.postImageView.image = posts[indexPath.row].image
        
        return cell
    }
}