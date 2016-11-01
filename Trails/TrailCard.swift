//
//  TrailCard.swift
//  Trails
//
//  Created by Rui Policarpo on 24/07/16.
//  Copyright © 2016 nExp. All rights reserved.
//

import Foundation
import UIKit

class TrailCard: UIView{

    var view: UIView!
    var serverImage:Bool = false
    @IBOutlet weak var trailImagePreview: UIImageView!
    @IBOutlet weak var trailCode: UILabel!
    @IBOutlet weak var trailName: UILabel!
    
    func xibSetup() {
        
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        view.layer.cornerRadius = 10
        self.addGradient()
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "TrailCard", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }

    
    func addGradient(){
        
        let gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame.size = self.trailImagePreview.frame.size
        gradient.colors = [UIColor.whiteColor().colorWithAlphaComponent(0).CGColor, UIColor.whiteColor().CGColor]
        gradient.locations = [0.5 , 1.0]
        self.trailImagePreview.layer.addSublayer(gradient)
        
    }

}