//
//  TopRoundedCornersView.swift
//  FluxInj3ct IV
//
//  Created by Justin Proulx on 2018-12-14.
//  Copyright © 2018 New Year's Development Team. All rights reserved.
//

import UIKit

class ActionCard: UIView {
    var visualEffectView: UIVisualEffectView!
    
    var isExpanded = false {
        didSet {
            self.layoutEverything()
            self.heightConstraint?.constant = 64
            
            self.bottomConstraint?.constant = self.defaultOffset
            
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                self.layoutEverything()
            })
        }
    }
    
    var heightConstraint: NSLayoutConstraint?
    var bottomConstraint: NSLayoutConstraint?
    
    var defaultOffset: CGFloat { isExpanded ? 64 : self.bounds.height-96 }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        setBlur()
        setDropShadow()
        
        let pullGesture = UIPanGestureRecognizer(target: self, action: #selector(handleActionViewPull))
        self.addGestureRecognizer(pullGesture)
        
        self.widthAnchor.constraint(lessThanOrEqualTo: superview!.widthAnchor).isActive = true
        self.widthAnchor.constraint(equalToConstant: 500).isActive = true
        self.centerXAnchor.constraint(equalTo: superview!.centerXAnchor).isActive = true
        
        heightConstraint = self.heightAnchor.constraint(equalTo: superview!.heightAnchor, multiplier: 3/4)
        heightConstraint?.constant = 64
        heightConstraint?.isActive = true
        
        bottomConstraint = self.bottomAnchor.constraint(equalTo: self.superview!.bottomAnchor, constant: 64)
        bottomConstraint?.isActive = true
        bottomConstraint?.priority = .required
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        doCornerRadius()
    }
    
    func doCornerRadius() {
        let cornerRadius = self.bounds.size.width/8
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        self.layer.mask = shape
    }
    
    func setBlur() {
        self.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
        visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = self.bounds
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(visualEffectView)
        self.sendSubviewToBack(visualEffectView)
        
        visualEffectView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        visualEffectView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        visualEffectView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        for subview in subviews where subview != visualEffectView {
            self.bringSubviewToFront(subview)
        }
        
        self.layoutEverything()
    }
    
    func setDropShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowRadius = 20
    }
    
    // MARK: – Pull State Change
    @objc func handleActionViewPull(sender: UIPanGestureRecognizer) {
        self.layoutEverything()
        
        let lightImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        lightImpactFeedbackGenerator.prepare()
        
        let drag = sender.translation(in: self).y
        let offsetY = stretchTranslation(fingerDrag: drag, springMath: customSpringMathFunction)
        
        if sender.state == .ended || sender.state == .cancelled || sender.state == .failed {
            if self.isExpanded ? drag > 150 : drag < -150 {
                self.isExpanded = !self.isExpanded
                lightImpactFeedbackGenerator.impactOccurred()
            } else {
                self.snapBack(from: offsetY)
            }
        } else {
            setCardOffset(offset: offsetY)
        }
    }
    
    func snapBack(from offset: CGFloat) {
        self.layoutEverything()
        
        if offset > 0 {
            self.bottomConstraint?.constant = defaultOffset
        } else {
            self.heightConstraint?.constant = 64
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
            self.layoutEverything()
        })
    }
    
    func setCardOffset(offset: CGFloat) {
        if offset > 0 {
            bottomConstraint?.constant = defaultOffset + offset
        } else {
            heightConstraint?.constant = 64-offset
        }
    }
    
    func stretchTranslation(fingerDrag: CGFloat, springMath: (CGFloat) -> CGFloat) -> CGFloat {
        let translationAmount = springMath(fingerDrag)
        return translationAmount
    }
    
    func customSpringMathFunction(x: CGFloat) -> CGFloat { 3*(atan(x/512) * 180 / CGFloat.pi) }
    
    func layoutEverything() {
        self.superview!.layoutIfNeeded()
        self.layoutIfNeeded()
        self.visualEffectView.layoutIfNeeded()
    }
}
