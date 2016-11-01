//
//  LoginViewController.swift
//  Trails
//
//  Created by Rui Policarpo on 14/06/16.
//  Copyright © 2016 nExp. All rights reserved.
//

import UIKit
import Firebase
import Spinner
import Security
import CoreData

class LoginViewContoller: UIViewController {
    var managedObjectContext: NSManagedObjectContext?

    let toNewUser = "newUser"
    let toAlreadyUser = "alreadyUser"
    private let spinner = Spinner()
    var ref = FIRDatabaseReference.init()
    
    @IBOutlet weak var buttonRegister: Button01!
    @IBOutlet weak var buttonLogin: Button01!
    @IBOutlet weak var emailLoginView: UIView!
    @IBOutlet weak var emailRegisterView: UIView!
    @IBOutlet weak var buttonNotRegisted: UIButton!
    @IBOutlet weak var buttonAlreadyRegisted: UIButton!
    @IBOutlet weak var tfLoginEmail: UITextField!
    @IBOutlet weak var tfLoginPassword: UITextField!
    @IBOutlet weak var tfNewName: UITextField!
    @IBOutlet weak var tfNewEmail: UITextField!
    @IBOutlet weak var tfNewPassword: UITextField!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        buttonLogin.setTitle("Entrar", forState: .Normal)
        buttonRegister.setTitle("Registar", forState: .Normal)
        emailLoginView.hidden = false
        emailRegisterView.hidden = true
        buttonAlreadyRegisted.hidden = true
        buttonNotRegisted.hidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let name = defaults.stringForKey("userNameKey")
        let password = defaults.stringForKey("passwordKey")

        if (name != nil && password != nil) && name != "" && password != ""{
            self.loginWith(name!, password: password!)
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        tfNewName.text = ""
        tfNewEmail.text = ""
        tfNewPassword.text = ""
        tfLoginEmail.text = ""
        tfLoginPassword.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionNotRegistered(sender: AnyObject) {
        flip(toNewUser)
        buttonNotRegisted.hidden = true
        buttonAlreadyRegisted.hidden = false
    }
    
    @IBAction func actionAlreadyRegisted(sender: AnyObject) {
        flip(toAlreadyUser)
        buttonNotRegisted.hidden = false
        buttonAlreadyRegisted.hidden = true
    }
    
    @IBAction func actionLogin(sender: AnyObject) {
        dismissKeyboard()
        if (validateLoginData() == true)
        {
            self.loginWith(tfLoginEmail.text!, password: tfLoginPassword.text!)
        }
        else{
            let alertView = UIAlertController(title: "Atenção", message: "Insira e-mail e password" , preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func actionRegisterNewUser(sender: AnyObject) {
        dismissKeyboard()
        spinner.showInView(view, withTitle: "A registar utilizador")
        FIRAuth.auth()?.createUserWithEmail(self.tfNewEmail.text!, password: self.tfNewPassword.text!, completion: { (FIRUser, NSError) in
            if NSError != nil {
                self.spinner.hide()
                let alertView = UIAlertController(title: "Atenção", message: NSError?.localizedDescription , preferredStyle: .Alert)
                alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(alertView, animated: true, completion: nil)
            } else {
                let ref = FIRDatabase.database().reference().child("users").child((FIRUser?.uid)!)
                let featureDict = [ "name": self.tfNewName.text!, "level" : 1, "distance": 0, "points":0, "survey":false]
                ref.setValue(featureDict)
                
                ref.observeSingleEventOfType(FIRDataEventType.ChildAdded, withBlock: { (snapshot) in
                    
                })
                self.loginWith(self.tfNewEmail.text!, password: self.tfNewPassword.text!)
            }
        })
    }
    
    
    func validateLoginData() -> Bool{
        if (tfLoginEmail.text == "" || tfLoginPassword.text == ""){
            return false
        }else{
            return true
        }
    }
    
    func validateRegisterData(){
        
    }
    
    func flip(toView:String) {
        let transitionOptions: UIViewAnimationOptions = [.TransitionFlipFromRight, .ShowHideTransitionViews]
        
        UIView.transitionWithView(emailLoginView, duration: 0.5, options: transitionOptions, animations: {
            if toView == self.toNewUser{
                self.emailLoginView.hidden = true
            }else if toView == self.toAlreadyUser {
                self.emailRegisterView.hidden = true
            }
        }, completion: nil)
        
        UIView.transitionWithView(emailRegisterView, duration: 0.5, options: transitionOptions, animations: {
            if toView == self.toNewUser{
                self.emailRegisterView.hidden = false
            }else if toView == self.toAlreadyUser {
                self.emailLoginView.hidden = false
            }            }, completion: nil)
    }

    func save(email: NSString, password: NSString) {

        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(email, forKey: "userNameKey")
        defaults.setObject(password, forKey: "passwordKey")
        defaults.synchronize()
    }
    
    
    func loginWith(email:NSString, password:NSString){
        spinner.showInView(view, withTitle: "Loggin in")
        FIRAuth.auth()?.signInWithEmail(email as String, password: password as String) { (user, error) in
            if error != nil {
                self.spinner.hide()
                let alertView = UIAlertController(title: "Atenção", message: "E-mail e/ou password inválido!" , preferredStyle: .Alert)
                alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(alertView, animated: true, completion: nil)
                
            } else {
                self.save(email, password: password)
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(user?.uid, forKey: "userUid")
                self.spinner.hide()
                let viewController  =  self.storyboard!.instantiateViewControllerWithIdentifier("MainTabBarController")  as! CustomUITabBarController
                viewController.managedObjectContext = self.managedObjectContext;
                self.navigationController?.showViewController(viewController, sender: nil)
            }
        }
    }
}