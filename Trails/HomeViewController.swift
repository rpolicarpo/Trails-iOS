//
//  HomeViewController.swift
//  Trails
//
//  Created by Rui Policarpo on 03/04/16.
//  Copyright © 2016 nExp. All rights reserved.
//

import UIKit
import FirebaseAuth
import CoreData
import FirebaseDatabase
import Firebase

class HomeViewController: UIViewController {
    var managedObjectContext: NSManagedObjectContext?
    var ref = FIRDatabaseReference.init()
    var urlString:String!
    @IBOutlet weak var cardProfileView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var cardProfileBg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var walkedDistance: UILabel!
    let userDefauls = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var serveyDescription: UILabel!
    @IBOutlet weak var surveyView: UIView!
    @IBOutlet weak var surveyButton: Button01!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        cardProfileBg.layer.cornerRadius = 10
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height/2
        if let customTabBarController = self.tabBarController as? CustomUITabBarController {
            managedObjectContext = customTabBarController.managedObjectContext
        }
        let distanceSaved = userDefauls.stringForKey("distance")
        if (distanceSaved == nil){
            self.walkedDistance.text = "A carregar..."
        }else {
            self.walkedDistance.text = "\(String(distanceSaved!)) kms percorridos"
        }
        
        let shadowColor:CGColor =  UIColor.blackColor().CGColor
        let shadowOffset:CGSize = CGSizeMake(0.0, 0.0)
        let shadowRadius:CGFloat = 6.0
        let shadowOpacity:Float = 0.7
        
        self.serveyDescription.layer.shadowColor = shadowColor
        self.serveyDescription.layer.shadowOffset = shadowOffset
        self.serveyDescription.layer.shadowRadius = shadowRadius
        self.serveyDescription.layer.shadowOpacity = shadowOpacity
        
        if userDefauls.objectForKey("survey") != nil{
            self.surveyView.hidden = userDefauls.objectForKey("survey") as! Bool
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


        
        if (userDefauls.stringForKey("userUid") == userDefauls.stringForKey("lastLoginUserUid")){
            let distanceSaved = userDefauls.stringForKey("distance")
            self.walkedDistance.text = "\(String(distanceSaved!)) kms percorridos"
            self.userName.text = String(userDefauls.stringForKey("name")!)
        }else{
            self.walkedDistance.text = "A carregar..."
            self.userName.text = "A carregar..."
        }
        
        let userUid = userDefauls.stringForKey("userUid")
        ref = FIRDatabase.database().reference()
        ref.child("users").child(userUid!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            let UserNameFromSnapshot = snapshot.value!["distance"] as? Double
            self.walkedDistance.text = "\(String(UserNameFromSnapshot!)) kms percorridos"
            self.userName.text = snapshot.value!["name"] as? String
            
            self.userDefauls.setObject(snapshot.value!["name"] as? String, forKey: "name")
            self.userDefauls.setObject(snapshot.value!["distance"] as? Double, forKey: "distance")
            self.userDefauls.setObject(snapshot.value!["points"] as? Double, forKey: "points")
            self.userDefauls.setObject(snapshot.value!["level"] as? Double, forKey: "level")
            self.userDefauls.setObject(userUid, forKey: "lastLoginUserUid")
            let serveyBool:Bool = (snapshot.value!["survey"] as? Bool)!
            self.userDefauls.setObject(serveyBool, forKey: "survey")
            self.showServey(serveyBool)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func showServey(alreadyDone:Bool){
        if (alreadyDone){
        
        
        }else{
            ref = FIRDatabase.database().reference()
            ref.child("config").child("survey").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                let hiddenSurveyStatus = snapshot.value!["hidden"] as? Bool
                let descSurvey = snapshot.value!["description"] as? String
                let surveyURL = snapshot.value!["url"] as? String
                
                self.urlString = surveyURL!
                self.serveyDescription.text = descSurvey!
                self.surveyView.hidden = hiddenSurveyStatus!
                
                self.userDefauls.setObject(hiddenSurveyStatus, forKey: "hidden")
                self.userDefauls.setObject(descSurvey, forKey: "description")
                self.userDefauls.setObject(surveyURL, forKey: "url")
            }) { (error) in
                print(error.localizedDescription)
            }

        
        }
        
    }
    
    @IBAction func openServey(sender: AnyObject) {
//        let aWebView = UIWebView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
//        aWebView.delegate = nil
//        let url = NSURL (string: self.urlString!)
//        let requestObj = NSURLRequest(URL: url!)
//        aWebView.loadRequest(requestObj)
//        self.view.addSubview(aWebView)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let surveyVC = segue.destinationViewController as? SurveyViewController {
            surveyVC.url = urlString
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func logoutAction(sender: AnyObject) {
        
        let alertController = UIAlertController(title: "Definições", message: "", preferredStyle: .Alert)
       
        let changeProfile = UIAlertAction(title: "Editar perfil (brevemente)", style: .Default) { (action) in
        }
        changeProfile.enabled = false
        alertController.addAction(changeProfile)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
        }
        alertController.addAction(cancelAction)
        
        let destroyAction = UIAlertAction(title: "Logout", style: .Destructive) { (action) in
            try! FIRAuth.auth()!.signOut()
            self.navigationController?.popViewControllerAnimated(true)
        }
        alertController.addAction(destroyAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
        
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let detailViewController = segue.destinationViewController as? NewTrailActivity {
//            detailViewController.managedObjectContext = self.managedObjectContext
//        }
//    }
}



