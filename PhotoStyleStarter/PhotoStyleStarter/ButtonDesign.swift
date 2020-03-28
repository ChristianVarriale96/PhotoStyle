//
//  ButtonDesign.swift
//  PhotoStyle
//
//  Created by Christian Varriale on 27/03/2020.
//  Copyright © 2020 Christian Varriale. All rights reserved.
//

import Foundation
import UIKit

//Design
class roundButton: UIButton{
    override func didMoveToWindow() {
        self.backgroundColor = UIColor.darkGray
        self.layer.cornerRadius = self.frame.height / 2
        self.setTitleColor(.white, for: .normal)
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
}

class roundButtonPickImage: UIButton {
    override func didMoveToWindow() {
        self.backgroundColor = #colorLiteral(red: 0.9341233373, green: 0.6279269457, blue: 0.4747709036, alpha: 1)
        self.layer.cornerRadius = self.frame.height / 2
        self.setTitleColor(.white, for: .normal)
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
}
