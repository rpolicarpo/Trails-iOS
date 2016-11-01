//
//  LeafsViewController.swift
//  Trails
//
//  Created by Rui Policarpo on 03/04/16.
//  Copyright © 2016 nExp. All rights reserved.
//

import UIKit
import CircleProgressView
import CoreData

class LeafsViewController: UIViewController {
    
    @IBOutlet weak var leafsCounter: UILabel!
    @IBOutlet weak var progress1: CircleProgressView!
    @IBOutlet weak var progress2: CircleProgressView!
    @IBOutlet weak var progress3: CircleProgressView!
    @IBOutlet weak var progress4: CircleProgressView!
    @IBOutlet weak var medalsLabel: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    var managedObjectContext: NSManagedObjectContext?
    let userDefauls = NSUserDefaults.standardUserDefaults()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (userDefauls.objectForKey("points") != nil){
            self.setLeafsGraph(userDefauls.objectForKey("points")! as! Double)
        }
        
        let shadowColor:CGColor =  UIColor.blackColor().CGColor
        let shadowOffset:CGSize = CGSizeMake(0.0, 0.0)
        let shadowRadius:CGFloat = 6.0
        let shadowOpacity:Float = 0.7
        
        self.medalsLabel.layer.shadowColor = shadowColor
        self.medalsLabel.layer.shadowOffset = shadowOffset
        self.medalsLabel.layer.shadowRadius = shadowRadius
        self.medalsLabel.layer.shadowOpacity = shadowOpacity
        
        self.historyLabel.layer.shadowColor = shadowColor
        self.historyLabel.layer.shadowOffset = shadowOffset
        self.historyLabel.layer.shadowRadius = shadowRadius
        self.historyLabel.layer.shadowOpacity = shadowOpacity
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let customTabBarController = self.tabBarController as? CustomUITabBarController {
            managedObjectContext = customTabBarController.managedObjectContext
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func moreInfoAction(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Informação", message: "Por cada 100 metros, que realizas dentro de uma rota, recebes uma folha.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func medalsAction(sender: AnyObject) {
        performSegueWithIdentifier("medalsSegue", sender: nil)
    }
    @IBAction func historyAction(sender: AnyObject) {
        performSegueWithIdentifier("trailsHistory", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let trailsHistory = segue.destinationViewController as? HistoryViewController {
            trailsHistory.managedObjectContext = self.managedObjectContext
        }else if segue.destinationViewController.isKindOfClass(BadgesViewController) {
            let fetchRequest = NSFetchRequest(entityName: "Run")
            
            let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            do {
                let runs = try managedObjectContext!.executeFetchRequest(fetchRequest) as! [Run]
                let badgesTableViewController = segue.destinationViewController as! BadgesViewController
                badgesTableViewController.badgeEarnStatusesArray = BadgeController.sharedController.badgeEarnStatusesForRuns(runs)
            } catch {
                print("Fetch failed: \((error as NSError).localizedDescription)")
            }
        }
    }

    func setLeafsGraph(points: Double){
        var leafsCounterString = "\(Int(points))"
        var tempPoints = points
        if (tempPoints <= 100){
            progress1.progress = (tempPoints/100)
            leafsCounterString.appendContentsOf("/100")
        }
        if (tempPoints > 100 && tempPoints <= 300){
            progress1.progress = 1
            tempPoints -= 100
            progress2.progress = (tempPoints/200)
            leafsCounterString.appendContentsOf("/300")
        }
        if (tempPoints > 300 && tempPoints <= 600){
            progress1.progress = 1
            progress2.progress = 1
            tempPoints -= 300
            progress3.progress = (tempPoints/300)
            leafsCounterString.appendContentsOf("/600")
        }
        if (tempPoints > 600 && tempPoints <= 1100){
            progress1.progress = 1
            progress2.progress = 1
            progress3.progress = 1
            tempPoints -= 600
            progress4.progress = (tempPoints/500)
            leafsCounterString.appendContentsOf("/1100")
        }
        if (tempPoints > 1100){
            progress1.progress = 1
            progress2.progress = 1
            progress3.progress = 1
            progress4.progress = 1
        }
        leafsCounterString.appendContentsOf(" folhas")
        leafsCounter.text = leafsCounterString
    }
    
}

