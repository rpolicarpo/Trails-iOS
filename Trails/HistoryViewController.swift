//
//  HistoryViewController.swift
//  Trails
//
//  Created by Rui Policarpo on 15/08/16.
//  Copyright © 2016 nExp. All rights reserved.
//

import UIKit
import CoreData
import HealthKit

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var managedObjectContext: NSManagedObjectContext?
    var run = [NSManagedObject]()
    
    @IBOutlet weak var noEntriesView: UIView!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest(entityName: "Run")
        
        //3
        do {
            let results =
                try managedContext!.executeFetchRequest(fetchRequest)
            run = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        run = run.reverse()
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell =
            self.tableView.dequeueReusableCellWithIdentifier(
                "passActivityTrailCell", forIndexPath: indexPath)
                as! pastTrailsCell
        
        let oneRun = run[indexPath.row] as? Run
        
        cell.labelCode.text = oneRun?.trailCode as? String
        cell.labelName.text = oneRun?.trailName as? String
        
//        let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: oneRun!.distance.doubleValue)
        cell.labelDistance.text = String(format:"%.2f", (Double(oneRun!.distance)/1000)) + " kms"
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        cell.labelDate.text = dateFormatter.stringFromDate(oneRun!.timestamp)
        
//        let secondsQuantity = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: oneRun!.duration.doubleValue)
//        cell.labelDuration.text = "Time: " + secondsQuantity.description

        cell.labelCode.backgroundColor = kGR1
        cell.labelCode.textColor = UIColor.whiteColor()
        cell.labelCode.layer.cornerRadius = 10
        cell.labelCode.layer.masksToBounds = true
        let acessoryViewImageView = UIImageView.init(image: UIImage.init(named: "moreInfo"))
        acessoryViewImageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        cell.accessoryView = acessoryViewImageView
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (run.count == 0){
            noEntriesView.hidden = false
        }else {
            noEntriesView.hidden = true
        }
        return run.count
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            managedObjectContext?.deleteObject(run[indexPath.row])
            run.removeAtIndex(indexPath.row)
            do {
                try managedObjectContext!.save()
            } catch _ {
                
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("DetailTrailActivity", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailViewController = segue.destinationViewController as? PastTrailActivity {
            let index = sender as? NSIndexPath
            detailViewController.run = run[index!.row] as! Run
        }
    }
    @IBAction func backToLeafs(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

class pastTrailsCell: UITableViewCell {
    
    @IBOutlet weak var labelCode: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDistance: UILabel!

}