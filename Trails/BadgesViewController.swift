//
//  BadgesViewController.swift
//  Trails
//
//  Created by Rui Policarpo on 22/08/16.
//  Copyright © 2016 nExp. All rights reserved.
//

import HealthKit
import Foundation
import UIKit

class BadgesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    var badgeEarnStatusesArray: [BadgeEarnStatus]!
    
    let blackColor = UIColor.blackColor()
    let greenColor = kGR1
    let whiteCOlor = UIColor.whiteColor()
    let dateFormatter: NSDateFormatter = {
        let _dateFormatter = NSDateFormatter()
        _dateFormatter.dateStyle = .MediumStyle
        return _dateFormatter
    }()
    let transform = CGAffineTransformMakeRotation(CGFloat(M_PI/8.0))

    @IBOutlet weak var collectionView: UICollectionView!
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return badgeEarnStatusesArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BadgeCell", forIndexPath: indexPath) as! BadgeCollectionCell
        
        let badgeEarnStatus = badgeEarnStatusesArray[indexPath.row]
        
//        cell.silverImageView.hidden = (badgeEarnStatus.silverRun != nil)
//        cell.goldImageView.hidden = (badgeEarnStatus.goldRun != nil)
        
        if badgeEarnStatus.earned {
            
            cell.nameLabel.layer.shadowColor = UIColor.blackColor().CGColor
            cell.nameLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0)
            cell.nameLabel.layer.shadowRadius = 6.0
            cell.nameLabel.layer.shadowOpacity = 0.7
            
            cell.nameLabel.textColor = kWH1
            cell.nameLabel.text = badgeEarnStatus.badge.name!
            cell.descLabel.textColor = kWH1
//            cell.descLabel.text = dateFormatter.stringFromDate(earnRun.timestamp)
            cell.badgeImageView.image = UIImage(named: badgeEarnStatus.badge.imageName!)
//            cell.silverImageView.transform = transform
//            cell.goldImageView.transform = transform
            cell.userInteractionEnabled = true
            cell.descLabel.text = nil
            cell.badgeImageView.contentMode = .ScaleAspectFit
        }
        else {
            
            cell.nameLabel.layer.shadowColor = UIColor.clearColor().CGColor
            
            cell.nameLabel.textColor = blackColor
            cell.nameLabel.text = "Bloqueada"
            cell.descLabel.textColor = blackColor
            let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: badgeEarnStatus.badge.distance!)
            cell.descLabel.text = distanceQuantity.description
            cell.badgeImageView.image = UIImage(named: "lock")
            cell.badgeImageView.contentMode = .Center
            cell.userInteractionEnabled = false

        }

        let shadowColorBlack:CGColor =  UIColor.blackColor().CGColor
        let shadowOffset:CGSize = CGSizeMake(0.0, 0.0)
        let shadowRadius:CGFloat = 6.0
        let shadowOpacity:Float = 0.7
        let cornerRadius:CGFloat = cell.badgeImageView.frame.width/2
        cell.badgeImageView.layer.shadowColor = shadowColorBlack
        cell.badgeImageView.layer.shadowOffset = shadowOffset
        cell.badgeImageView.layer.shadowRadius = shadowRadius
        cell.badgeImageView.layer.shadowOpacity = shadowOpacity
        cell.badgeImageView.layer.cornerRadius = cornerRadius
        cell.badgeImageView.layer.masksToBounds = true
        cell.badgeImageView.layer.borderColor = UIColor.whiteColor().CGColor
        cell.badgeImageView.layer.borderWidth = 3
        
        return cell

    }
    @IBAction func backToLeafs(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("medalDetail", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.isKindOfClass(BadgeDetailsViewController) {
            let badgeDetailsViewController = segue.destinationViewController as! BadgeDetailsViewController
//            let badgeEarnStatus = badgeEarnStatusesArray[(tableView.indexPathForSelectedRow?.row)!]
            let indexPaths : NSArray = self.collectionView!.indexPathsForSelectedItems()!
            let indexPath : NSIndexPath = indexPaths[0] as! NSIndexPath
            let badgeEarnStatus = badgeEarnStatusesArray[indexPath.row]
            badgeDetailsViewController.badgeEarnStatus = badgeEarnStatus
        }
    }

}

class BadgeCollectionCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var badgeImageView: UIImageView!
}
