//
//  BadgeDetailsViewController.swift
//  Trails
//
//  Created by Rui Policarpo on 21/08/16.
//  Copyright © 2016 nExp. All rights reserved.
//

import UIKit
import HealthKit

class BadgeDetailsViewController: UIViewController {
    var badgeEarnStatus: BadgeEarnStatus!
    
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var silverImageView: UIImageView!
    @IBOutlet weak var goldImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var earnedLabel: UILabel!
    @IBOutlet weak var silverLabel: UILabel!
    @IBOutlet weak var goldLabel: UILabel!
    @IBOutlet weak var bestLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        
        let shadowColor:CGColor =  UIColor.blackColor().CGColor
        let shadowOffset:CGSize = CGSizeMake(0.0, 0.0)
        let shadowRadius:CGFloat = 6.0
        let shadowOpacity:Float = 0.7
        
        let cornerRadius:CGFloat = badgeImageView.frame.width/2
        badgeImageView.layer.cornerRadius = cornerRadius
        badgeImageView.layer.masksToBounds = true
        badgeImageView.layer.borderColor = UIColor.whiteColor().CGColor
        badgeImageView.layer.borderWidth = 5

        nameLabel.text = badgeEarnStatus.badge.name
        badgeImageView.image = UIImage(named: badgeEarnStatus.badge.imageName!)
        infoLabel.text = badgeEarnStatus.badge.information
        let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: badgeEarnStatus.badge.distance!)
        distanceLabel.text = distanceQuantity.description + " caminhados"
        
        self.distanceLabel.layer.shadowColor = shadowColor
        self.distanceLabel.layer.shadowOffset = shadowOffset
        self.distanceLabel.layer.shadowRadius = shadowRadius
        self.distanceLabel.layer.shadowOpacity = shadowOpacity
        
        self.infoLabel.textColor = UIColor.whiteColor()
        self.infoLabel.layer.shadowColor = shadowColor
        self.infoLabel.layer.shadowOffset = shadowOffset
        self.infoLabel.layer.shadowRadius = shadowRadius
        self.infoLabel.layer.shadowOpacity = shadowOpacity
        
        self.nameLabel.layer.shadowColor = shadowColor
        self.nameLabel.layer.shadowOffset = shadowOffset
        self.nameLabel.layer.shadowRadius = shadowRadius
        self.nameLabel.layer.shadowOpacity = shadowOpacity
        
        
//        let transform = CGAffineTransformMakeRotation(CGFloat(M_PI/8.0))
        
        
//        let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: badgeEarnStatus.badge.distance!)
//        distanceLabel.text = distanceQuantity.description

//
//        if let run = badgeEarnStatus.earnRun {
//            earnedLabel.text = "Reached on " + formatter.stringFromDate(run.timestamp)
//        }
//        
//        if let silverRun = badgeEarnStatus.silverRun {
//            silverImageView.transform = transform
//            silverImageView.hidden = false
//            silverLabel.text = "Earned on " + formatter.stringFromDate(silverRun.timestamp)
//        }
//        else {
//            silverImageView.hidden = true
//            let paceUnit = HKUnit.secondUnit().unitDividedByUnit(HKUnit.meterUnit())
//            let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: badgeEarnStatus.earnRun!.duration.doubleValue / badgeEarnStatus.earnRun!.distance.doubleValue)
//            silverLabel.text = "Pace < \(paceQuantity.description) for silver!"
//        }
//        
//        if let goldRun = badgeEarnStatus.goldRun {
//            goldImageView.transform = transform
//            goldImageView.hidden = false
//            goldLabel.text = "Earned on " + formatter.stringFromDate(goldRun.timestamp)
//        }
//        else {
//            goldImageView.hidden = true
//            let paceUnit = HKUnit.secondUnit().unitDividedByUnit(HKUnit.meterUnit())
//            let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: badgeEarnStatus.earnRun!.duration.doubleValue / badgeEarnStatus.earnRun!.distance.doubleValue)
//            goldLabel.text = "Pace < \(paceQuantity.description) for gold!"
//        }
//        
//        if let bestRun = badgeEarnStatus.bestRun {
//            let paceUnit = HKUnit.secondUnit().unitDividedByUnit(HKUnit.meterUnit())
//            let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: bestRun.duration.doubleValue / bestRun.distance.doubleValue)
//            bestLabel.text = "Best: \(paceQuantity.description), \(formatter.stringFromDate(bestRun.timestamp))"
//        }
        
    }
    
    @IBAction func backToBadgesAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}