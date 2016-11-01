//
//  Badge.swift
//  Trails
//
//  Created by Rui Policarpo on 21/08/16.
//  Copyright © 2016 nExp. All rights reserved.
//

import Foundation

let silverMultiplier = 1.05 // 5% speed increase
let goldMultiplier = 1.10 // 10% speed increase

class Badge {
    let name: String?
    let imageName: String?
    let information: String?
    let distance: Double?
    
    init(json: [String: String]) {
        name = json["name"]
        information = json["information"]
        imageName = json["imageName"]
        distance = Double(json["distance"]!)
    }
}

class BadgeController {
    static let sharedController = BadgeController()
    let userDefauls = NSUserDefaults.standardUserDefaults()

    lazy var badges : [Badge] = {
        var _badges = [Badge]()
        
        let filePath = NSBundle.mainBundle().pathForResource("badges", ofType: "json") as String!
        let jsonData = NSData.dataWithContentsOfMappedFile(filePath) as! NSData
        
        do {
            let jsonBadges = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.AllowFragments)
            for jsonBadge in jsonBadges as! [AnyObject] {
                _badges.append(Badge(json: jsonBadge as! [String : String]))
            }
        } catch {
            print("Fetch failed: \((error as NSError).localizedDescription)")
        }
        return _badges
    }()
    
    func badgeEarnStatusesForRuns(runs: [Run]) -> [BadgeEarnStatus] {
        var badgeEarnStatuses = [BadgeEarnStatus]()
        let distanceSaved = Double(userDefauls.stringForKey("distance")!)

        for badge in badges {
            let badgeEarnStatus = BadgeEarnStatus(badge: badge)
            
            if distanceSaved > (badge.distance!/1000) {
                badgeEarnStatus.earned = true
            }
            
            for run in runs {
                if run.distance.doubleValue > badge.distance {
                    // This is when the badge was first earned
                    if badgeEarnStatus.earnRun == nil {
                        badgeEarnStatus.earnRun = run
                    }
                    
                    let earnRunSpeed = badgeEarnStatus.earnRun!.distance.doubleValue / badgeEarnStatus.earnRun!.duration.doubleValue
                    let runSpeed = run.distance.doubleValue / run.duration.doubleValue
                    
                    // Does it deserve silver?
                    if badgeEarnStatus.silverRun == nil && runSpeed > earnRunSpeed * silverMultiplier {
                        badgeEarnStatus.silverRun = run
                    }
                    
                    // Does it deserve gold?
                    if badgeEarnStatus.goldRun == nil && runSpeed > earnRunSpeed * goldMultiplier {
                        badgeEarnStatus.goldRun = run
                    }
                    
                    // Is it the best for this distance?
                    if let bestRun = badgeEarnStatus.bestRun {
                        let bestRunSpeed = bestRun.distance.doubleValue / bestRun.duration.doubleValue
                        if runSpeed > bestRunSpeed {
                            badgeEarnStatus.bestRun = run
                        }
                    }
                    else {
                        badgeEarnStatus.bestRun = run
                    }
                }
            }
            
            badgeEarnStatuses.append(badgeEarnStatus)
        }
        
        return badgeEarnStatuses
    }
}

class BadgeEarnStatus {
    var earned: Bool = false
    let badge: Badge
    var earnRun: Run?
    var silverRun: Run?
    var goldRun: Run?
    var bestRun: Run?
    
    init(badge: Badge) {
        self.badge = badge
    }
}
