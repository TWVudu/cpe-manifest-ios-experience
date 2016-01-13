//
//  ViewController.swift
//  NextGenPOC-Native
//
//  Created by Sedinam Gadzekpo on 1/7/16.
//  Copyright © 2016 Sedinam Gadzekpo. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var slideOutMenu: UITableView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var extView: UIView!
    @IBOutlet weak var playMovie: UIButton!
    @IBOutlet weak var extras: UIButton!
    @IBOutlet var LtoR: UISwipeGestureRecognizer!
    @IBOutlet var RtoL: UISwipeGestureRecognizer!
    
    
    let navImages = ["nav_extras.jpg","nav_home.jpg","nav_scenes.jpg"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.LtoR.direction = UISwipeGestureRecognizerDirection.Right
        self.RtoL.direction = UISwipeGestureRecognizerDirection.Left
        
        self.slideOutMenu.hidden = true
        
        
        
        let extraBG = UIImageView(image: UIImage(named: "home_extras_bg.jpg")!)
        
        let extraBTS = UIImageView(image: UIImage(named: "home_extras_bts.jpg")!)
        let extraCast = UIImageView(image: UIImage(named: "home_extras_cast.jpg")!)
        let extraMaps = UIImageView(image: UIImage(named: "home_extras_maps.jpg")!)
        let extraShop = UIImageView(image: UIImage(named: "home_extras_shop.jpg")!)
        
        
        if(UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeLeft || UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeRight)
        {
            
            self.extView.hidden = true
            extraBG.frame = CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.height, (UIScreen.mainScreen().bounds.width)/2)
            
        }else {
            
            extraBG.frame = CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, (UIScreen.mainScreen().bounds.height)/2)
            
        }
        
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "detectRotation", name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
        
        
        self.playerView.backgroundColor = UIColor (patternImage: UIImage(named: "home_bg.jpg")!)
        
        
        
        //CGRects for the extra images are hard coded for now
        
        extraBTS.frame = CGRectMake(50, 80, 400.0, 300.0)
        extraMaps.frame = CGRectMake(570, 80, 400.0, 300.0)
        extraCast.frame = CGRectMake(50, 370, 400.0, 300.0)
        extraShop.frame = CGRectMake(570, 370, 400.0, 300.0)
        
        self.extView.addSubview(extraBG)
        self.extView.addSubview(extraBTS)
        self.extView.addSubview(extraCast)
        self.extView.addSubview(extraMaps)
        self.extView.addSubview(extraShop)
        
        
        self.slideOutMenu.delegate = self
        self.slideOutMenu.registerClass(UITableViewCell.self, forCellReuseIdentifier: "menuItem")
        self.slideOutMenu.backgroundColor = UIColor(patternImage: UIImage(named: "menu_bg.jpg")!)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    
    
    
    @IBAction func slideMenu(recognizer: UISwipeGestureRecognizer) {
        
        if(recognizer.direction == UISwipeGestureRecognizerDirection.Right){
            
            self.slideOutMenu.hidden = false
        } else if (recognizer.direction == UISwipeGestureRecognizerDirection.Left) {
            self.slideOutMenu.hidden = true
        }
    }
    
    
    func detectRotation(){
        
        
        if(UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeLeft || UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeRight)
        {
            self.extView.hidden = true
            
            
        }else if (UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.Portrait || UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.PortraitUpsideDown)
        {
            self.extView.hidden = false
            
            
        }
        
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.navImages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("menuItem", forIndexPath: indexPath) as UITableViewCell
        let row = indexPath.row
        cell.backgroundColor = UIColor(patternImage: UIImage(named: "menu_bg.jpg")!)
        cell.imageView?.image = UIImage (named: navImages[row])
        
        
        return cell
    }
    
}
