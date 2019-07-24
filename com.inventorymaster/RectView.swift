//
//  RectView.swift
//  com.inventorymaster
//
//  Created by Alex on 7/24/19.
//  Copyright © 2019 Alex Mytnyk. All rights reserved.
//

import UIKit

class RectView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        //context.setStrokeColor(UIColor.orange.cgColor)
        context.setStrokeColor(UIColor.orange.cgColor)
        context.setLineWidth(2)
        //context.setLineWidth(4)
        //context.addRect(CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5))
        
        let width = self.bounds.width / 2
        let height = self.bounds.height / 2
        
        context.stroke(CGRect(x: width / 2, y: height / 2, width: width, height:  height))
    }
}
