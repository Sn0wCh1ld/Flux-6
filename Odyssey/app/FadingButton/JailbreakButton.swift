//
//  JailbreakButton.swift
//  FluxInj3ct IV
//
//  Created by Justin Proulx on 2018-12-22.
//  Copyright © 2018 New Year's Development Team. All rights reserved.
//

import UIKit

class JailbreakButton: FadingButton {
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        doCircleRadius()
        setColors()
        self.contentEdgeInsets = UIEdgeInsets(top: 16, left: 30, bottom: 16, right: 30)
        self.titleLabel?.font = .boldSystemFont(ofSize: 24)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        doCircleRadius()
    }
    
    func setColors() {
        self.tintColor = UIColor(red: 0.30, green: 0.44, blue: 0.50, alpha: 0.1)
        self.backgroundColor = self.tintColor
        self.setTitleColor(.white, for: .normal)
    }
    
    func doCircleRadius() {
        self.layer.cornerRadius = min(self.bounds.size.width, self.bounds.size.height) / 4
    }
}
