//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Rebecca Poch on 6/29/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit

var photoTakingHelper: PhotoTakingHelper?

class TimelineViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tabBarController?.delegate = self //since timeline is the first view that is loaded, put delegate in here
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
            //don't do anything yet
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