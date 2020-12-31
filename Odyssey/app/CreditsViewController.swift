//
//  CreditsViewController.swift
//  Odyssey
//
//  Created by Justin Proulx on 2020-12-31.
//  Copyright © 2020 coolstar. All rights reserved.
//

import UIKit

class CreditsViewController: UIViewController {
    
    struct Credit {
        let name: String
        let handle: String
    }
    
    let credits = [
        Credit(name: "CoolStar", handle: "CStar_OW"),
        Credit(name: "Hayden Seay", handle: "Diatrus"),
        Credit(name: "23 Aaron", handle: "23Aaron_"),
        Credit(name: "Tihmstar", handle: "tihmstar")
    ]
    
    let s0uthwes = Credit(name: "Kúp", handle: "s0uthwes")
    
    var visualEffectView: UIVisualEffectView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setBlur()
        setUpCreditStack()
    }
    
    func setUpCreditStack() {
        let superStack = UIStackView()
        superStack.axis = .vertical
        superStack.spacing = 48
        superStack.translatesAutoresizingMaskIntoConstraints = false
        
        let devCreditsStack = UIStackView()
        devCreditsStack.axis = .vertical
        devCreditsStack.spacing = 16
        
        for credit in credits {
            let button = TwitterButton(handle: credit.handle)
            button.setTitle(credit.name, for: .normal)
            devCreditsStack.addArrangedSubview(button)
        }
        superStack.addArrangedSubview(devCreditsStack)
        
        let memorialStack = UIStackView()
        memorialStack.axis = .vertical
        memorialStack.spacing = 16
        
        let s0uthwesButton = TwitterButton(handle: s0uthwes.handle)
        s0uthwesButton.setTitle(s0uthwes.name, for: .normal)
        memorialStack.addArrangedSubview(s0uthwesButton)
        
        let memorialLabel = UILabel()
        memorialLabel.numberOfLines = 0
        memorialLabel.textAlignment = .center
        memorialLabel.text = "The original Odyssey jailbreak was created in memory of s0uthwes, a member of the jailbreak community and friend to many"
        memorialStack.addArrangedSubview(memorialLabel)
        
        superStack.addArrangedSubview(memorialStack)
        
        self.view.addSubview(superStack)
        
        superStack.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        superStack.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        superStack.widthAnchor.constraint(equalToConstant: 250).isActive = true
    }
    
    func setBlur() {
        self.view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .regular)
        visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = self.view.bounds
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(visualEffectView)
        self.view.sendSubviewToBack(visualEffectView)
        
        visualEffectView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        visualEffectView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        visualEffectView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        for subview in self.view.subviews where subview != visualEffectView {
            self.view.bringSubviewToFront(subview)
        }
        
        self.view.layoutIfNeeded()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
