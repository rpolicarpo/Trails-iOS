//
//  SurveyViewController.swift
//  Trails
//
//  Created by Rui Policarpo on 03/09/16.
//  Copyright © 2016 nExp. All rights reserved.
//

import Foundation
import UIKit
import Spinner
import FirebaseDatabase

class SurveyViewController: UIViewController, UIWebViewDelegate{

    var url:String!
    private let spinner = Spinner()
    @IBOutlet weak var cancelButton: Button02!
    @IBOutlet weak var okButton: Button01!
    var ref = FIRDatabaseReference.init()
    let userDefauls = NSUserDefaults.standardUserDefaults()

    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {

                webView.delegate = self
                let url = NSURL (string: self.url!)
                let requestObj = NSURLRequest(URL: url!)
                webView.loadRequest(requestObj)
                self.view.addSubview(webView)
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        spinner.showInView(view, withTitle: "A carregar questionário")
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        let html = webView.stringByEvaluatingJavaScriptFromString("document.body.innerHTML")!
        if html.rangeOfString("terms") == nil{
            cancelButton.hidden = true
            okButton.hidden = false
        }
        
        self.spinner.hide()
    }

    @IBAction func okButtonAction(sender: AnyObject) {
        spinner.showInView(view, withTitle: "A guardar inquérito")

        
        let ref = FIRDatabase.database().reference().child("users").child((userDefauls.objectForKey("userUid") as? String)!)
        ref.updateChildValues(["survey":true, "points":(userDefauls.objectForKey("points") as! Int)+50])
        ref.observeSingleEventOfType(FIRDataEventType.ChildChanged, withBlock: { (snapshot) in
        })
        self.userDefauls.setObject((userDefauls.objectForKey("points") as! Int)+50, forKey: "points")
        self.userDefauls.setObject(true, forKey: "survey")
        self.spinner.hide()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelButtonAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
