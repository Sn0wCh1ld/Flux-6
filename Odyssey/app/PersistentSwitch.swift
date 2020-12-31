//
//  PersistentSwitch.swift
//  Odyssey
//
//  Created by Justin Proulx on 2020-12-31.
//  Copyright © 2020 coolstar. All rights reserved.
//

import UIKit

class PersistentSwitch: UISwitch {

    let defaultValue: Bool
    let key: String
    
    init(key: String, defaultValue: Bool) {
        self.key = key
        self.defaultValue = defaultValue
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.awakeFromNib()
        
        self.addTarget(self, action: #selector(switchChanged), for: .touchUpInside)
        
        if !keyExists(key: self.key) {
            UserDefaults.standard.set(defaultValue, forKey: self.key)
        }
        
        self.setOn(UserDefaults.standard.bool(forKey: self.key), animated: false)
    }
    
    func keyExists(key: String) -> Bool {
        let res = UserDefaults.standard.object(forKey: key)
        return res != nil
    }
    
    @objc func switchChanged() {
        UserDefaults.standard.set(self.isOn, forKey: self.key)
    }
}
