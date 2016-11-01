//
//  SingleTrailDetail.swift
//  Trails
//
//  Created by Rui Policarpo on 02/08/16.
//  Copyright © 2016 nExp. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import Spinner
import CoreData

class SingleTrailDetail: UIViewController, TrailDetailsDelegate{
    @IBOutlet weak var trailDetailsContainer: TrailDetaisViewController!
    var ref = FIRDatabaseReference.init()
    var trailsArray = [FIRDataSnapshot]()
    private let spinner = Spinner()
    var trailId:String = ""
    var managedObjectContext: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trailDetailsContainer.delegate = self
        trailDetailsContainer.carousel.scrollEnabled = false
        trailDetailsContainer.carousel.reloadData()
        getTrailsNearby()
        trailDetailsContainer.comeFrom = Constants.singleDetailController
        if let customTabBarController = self.tabBarController as? CustomUITabBarController {
            managedObjectContext = customTabBarController.managedObjectContext
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTrailsArray () -> NSArray{
        //ISTO PODE NAO RESOLVER

        return trailsArray
    }
    
    func getTrailsNearby() {
        spinner.showInView(view, withTitle: "A carregar detalhes")
        ref = FIRDatabase.database().reference()
        ref.child("trails").child("detailInfo").child(trailId).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                self.trailsArray.append(snapshot)
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
        ref.child("trails").child("detailInfo").child(trailId).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                self.trailsArray.append(snapshot)
            self.trailDetailsContainer.carousel.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }



    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func goToTrailActivity() {
        self.performSegueWithIdentifier("trailNewActivity", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailViewController = segue.destinationViewController as? NewTrailActivity {
            detailViewController.managedObjectContext = self.managedObjectContext
        }
    }

}