//
//  NearbyViewController.swift
//  Trails
//
//  Created by Rui Policarpo on 03/04/16.
//  Copyright © 2016 nExp. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Spinner
import CoreData

struct Constants {
    static let nearbyController = "nearbyController"
    static let singleDetailController = "singleDetailController"
}

class NearbyViewController: UIViewController, TrailDetailsDelegate {
    @IBOutlet weak var trailDetailsContainer: TrailDetaisViewController!
    var ref = FIRDatabaseReference.init()
    var trailsArray = [FIRDataSnapshot]()
    private let spinner = Spinner()
    var managedObjectContext: NSManagedObjectContext?
    var selectedTrailRef:NSString = NSString()
    var selectedTrailName:NSString = NSString()
    var selectedTrailCode:NSString = NSString()
    var selectedAnnotations:NSArray = NSArray()
    var selectedOverlays:NSArray = NSArray()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        trailDetailsContainer.delegate = self
        trailDetailsContainer.carousel.reloadData()
        getTrailsNearby()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let customTabBarController = self.tabBarController as? CustomUITabBarController {
            managedObjectContext = customTabBarController.managedObjectContext
        }
        trailDetailsContainer.comeFrom = Constants.nearbyController
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTrailsArray () -> NSArray{
        //ISTO PODE NAO RESOLVER
        if trailsArray.count < 20 {
            trailsArray += trailsArray
        }
        
        return trailsArray
    }
    
    func getTrailsNearby() {
        spinner.showInView(view, withTitle: "Procurando rotas")
        ref = FIRDatabase.database().reference()
        ref.child("trails").child("detailInfo").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                self.trailsArray.append(rest)
            }
            self.trailDetailsContainer.carousel.reloadData()
            self.spinner.hide()
        }) { (error) in
            self.spinner.hide()
            print(error.localizedDescription)
        }
    }
    
    func getUpdateData(){
        ref = FIRDatabase.database().reference()
        trailsArray.removeAll()
        ref.child("trails").child("detailInfo").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                self.trailsArray.append(rest)
            }
            self.trailDetailsContainer.carousel.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func goToTrailActivity(ref:NSString, code:NSString, name:NSString, annorations:NSArray, overlays:NSArray) {
        self.selectedTrailRef = ref
        self.selectedTrailName = name
        self.selectedTrailCode = code
        self.selectedAnnotations = annorations
        self.selectedOverlays = overlays
        self.performSegueWithIdentifier("trailNewActivity", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailViewController = segue.destinationViewController as? NewTrailActivity {
            detailViewController.managedObjectContext = self.managedObjectContext
            detailViewController.trailName = self.selectedTrailName
            detailViewController.trailCode = self.selectedTrailCode
            detailViewController.trailRef = self.selectedTrailRef
            detailViewController.annotations = self.selectedAnnotations
            detailViewController.overlays = self.selectedOverlays
        }
    }
}

