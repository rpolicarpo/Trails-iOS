//
//  Button02.swift
//  Trails
//
//  Created by Rui Policarpo on 19/06/16.
//  Copyright © 2016 nExp. All rights reserved.
//

import UIKit

//@IBDesignable
class Button02: UIButton {
    
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        normalStateUI()
        
        self.layer.shadowColor = kBK1.CGColor
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = false;
        self.clipsToBounds = false;
        
        self.setTitleColor(kBK2, forState: UIControlState.Normal)
        self.setTitleColor(kBK2, forState: UIControlState.Highlighted)
        
        
    }
    
    override var highlighted: Bool {
        didSet {
            
            if (highlighted) {
                highlightedStateUI()
            }
            else {
                normalStateUI()
            }
            
        }
    }
    
    func normalStateUI(){
        self.layer.backgroundColor = kWH1A70.CGColor
        self.layer.shadowOffset = CGSizeMake(0, 8)
        self.layer.shadowOpacity = 0.4
    }
    
    func highlightedStateUI(){
        self.layer.backgroundColor = kWH1A50.CGColor
        self.layer.shadowOffset = CGSizeMake(0, 4)
        self.layer.shadowOpacity = 0.6
    }
    
    override func prepareForInterfaceBuilder() {
        self.setTitle("Button02", forState: .Normal)
    }
}
