//
//  TwitterButton.swift
//  FluxInj3ct IV
//
//  Created by Justin Proulx on 2018-12-22.
//  Copyright © 2018 New Year's Development Team. All rights reserved.
//

import UIKit

class TwitterButton: ImpressionableButton {
    var handle: String?
    
    init(handle: String = "", customAction: Bool = false) {
        super.init(frame: .zero)
        
        self.handle = handle
        
        if !customAction {
            self.addTarget(self, action: #selector(openTwitter), for: .touchUpInside)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        setColors()
        doCircleRadius()
        self.contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupShadow()
        setColors()
        doCircleRadius()
    }
    
    func setColors() {
        self.backgroundColor = self.tintColor
        self.setTitleColor(.white, for: .normal)
    }
    
    func doCircleRadius() {
        self.layer.cornerRadius = min(self.bounds.size.width, self.bounds.size.height) / 4
    }
    
    func setupShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowOpacity = 0.1
    }
    
    @objc func openTwitter()
    {
        let normalURL = URL(string: "https://twitter.com/" + handle!)
        let twitterURL = URL(string: "twitter://user?screen_name=" + handle!)
        
        if UIApplication.shared.canOpenURL(twitterURL!)
        {
            UIApplication.shared.open(twitterURL!, options:[:], completionHandler: nil)
        }
        else
        {
            UIApplication.shared.open(normalURL!, options:[:] , completionHandler: nil)
        }
    }
}
