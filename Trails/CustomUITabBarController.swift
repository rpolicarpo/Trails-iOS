//
//  CustomUITabBarController.swift
//  Trails
//
//  Created by Rui Policarpo on 03/04/16.
//  Copyright © 2016 nExp All rights reserved.
//

import UIKit
import CoreData

class CustomUITabBarController: UITabBarController {
    
    var managedObjectContext: NSManagedObjectContext?
    
    enum MenuSections: Int {
        case SectionNearby = 0, SectionLeafs, SectionHome, SectionNature, SectionMap
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedIndex = MenuSections.SectionHome.rawValue
        self.tabBar.setValue(true, forKey: "_hidesShadow")


    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
