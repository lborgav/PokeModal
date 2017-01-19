//
//  PokeModal.swift
//  PokeModal
//
//  Created by Leonardo Borges Avelino on 8/3/16.
//  Copyright © 2016 Leonardo Borges Avelino. All rights reserved.
//

import Foundation
import UIKit

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}



@objc public protocol PokeModalDelegate {
    @objc optional func pokeModalWillHide()
}

open class PokeModal: UIResponder {
    
    fileprivate var containerView: UIView?
    fileprivate var buttonImage: UIImage?
    fileprivate var titleLabel: UILabel?
    fileprivate var contentLabel: UILabel?
    fileprivate var closeButton: UIButton?
    fileprivate var isShown: Bool? = false
    fileprivate var view: UIView?
    fileprivate var initialPoint: CGPoint?
    
    open var delegate: PokeModalDelegate?
    
    open var titleText: String = "TITLE" {
        didSet { }
    }
    
    open var contentText: String = "Content" {
        didSet { }
    }
    
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    
    public init(view: UIView) {
        super.init()
        
        self.view = view
        
        containerView = UIView(frame: CGRect(x: 30, y: screenHeight, width: screenWidth - 60
            , height: screenHeight / 2.0))
        containerView?.backgroundColor = UIColor.white
        
        containerView?.layer.borderWidth = 0.0
        containerView?.layer.borderColor = UIColor ( red: 0.2608, green: 0.8168, blue: 0.8177, alpha: 1.0 ).cgColor
        
        containerView?.layer.shadowOffset = CGSize.zero
        containerView?.layer.shadowOpacity = 1
        containerView?.layer.shadowColor = UIColor ( red: 0.6699, green: 0.6941, blue: 0.7486, alpha: 1.0 ).cgColor
        containerView?.layer.shadowRadius = 10
        
        // Dealing with bundles...
        let podBundle = Bundle(for: self.classForCoder)
        if let bundleURL = podBundle.url(forResource: "PokeModal", withExtension: "bundle") {
            if let bundle = Bundle(url: bundleURL) {
                buttonImage = UIImage(named: "close", in: bundle, compatibleWith: nil)
            }else {
                assertionFailure("Could not load the bundle")
            }
        }else {
            assertionFailure("Could not create a path to the bundle")
        }
        
        
        
        titleLabel = UILabel(frame: CGRect(x: (screenWidth - 60) / 2.0 - 80, y: 0, width: 160, height: 40))
        titleLabel?.textAlignment = .center
        titleLabel?.backgroundColor = UIColor.clear
        
        contentLabel = UILabel(frame: CGRect(x: 20, y: 70, width: screenWidth - 60 - 40, height: 80))
        contentLabel?.textAlignment = .center
        contentLabel?.numberOfLines = 0
        contentLabel?.backgroundColor = UIColor.clear
        
        closeButton = UIButton(frame: CGRect(x: (screenWidth - 60) / 2.0 - 25, y: self.screenHeight / 2.0 - 80, width: 50, height: 50))
        closeButton?.backgroundColor = UIColor.clear
        closeButton?.setBackgroundImage(buttonImage, for: UIControlState())
        closeButton?.setTitle("", for: UIControlState())
        closeButton?.addTarget(self, action: #selector(PokeModal.dismissMenu), for: UIControlEvents.touchUpInside)
        
        
        let downGesture = UIPanGestureRecognizer(target: self, action: #selector(PokeModal.swipedDown))
        containerView?.addGestureRecognizer(downGesture)
    }
    
    open func showMenu() -> Void {
        if isShown == false {
            
            if closeButton != nil {
                self.containerView?.addSubview(closeButton!)
            }
            
            if titleLabel != nil {
                titleLabel?.font = UIFont(name: "Avenir-Black", size: 15)
                titleLabel?.addCharactersSpacing(3, text: self.titleText)
                titleLabel?.layer.addLateralBorder(UIRectEdge.bottom, color: UIColor.black, thickness: 1)
                self.containerView?.addSubview(titleLabel!)
            }
            
            if contentLabel != nil {
                contentLabel?.font = UIFont(name: "Avenir-Book", size: 12)
                contentLabel?.text = self.contentText
                contentLabel?.backgroundColor = UIColor.clear
                self.containerView?.addSubview(contentLabel!)
            }
            
            self.view!.addSubview(self.containerView!)
            self.view!.bringSubview(toFront: self.containerView!)
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.containerView?.frame = CGRect(x: 30, y: self.screenHeight / 2.0, width: self.screenWidth - 60, height: self.screenHeight / 2.0)
            }, completion: nil)
            
            
        }
        isShown = true
    }
    
    open func dismissMenu() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.containerView?.frame = CGRect(x: 30, y: self.screenHeight, width: self.screenWidth - 60, height: self.screenHeight / 2.0)
        }, completion: { (Bool) -> Void in
            self.removeSubviews()
            self.containerView!.removeFromSuperview()
            self.isShown = false
            if self.delegate != nil {
                self.delegate?.pokeModalWillHide!()
            }
        })
        
    }
    
}

private extension PokeModal {
    
    @objc func swipedDown(_ sender: UIPanGestureRecognizer) -> Void {
        
        let translation = sender.translation(in: self.view)
        
        if sender.state == UIGestureRecognizerState.began {
            self.initialPoint = self.containerView?.center
        }
        
        if let senderView = sender.view {
            if translation.y > 0 {
                senderView.center = CGPoint(x: senderView.center.x, y: senderView.center.y + translation.y)
            }
            else {
                if senderView.center.y > self.initialPoint?.y {
                    senderView.center = CGPoint(x: senderView.center.x, y: senderView.center.y + translation.y)
                }
            }
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
        
        if sender.state == UIGestureRecognizerState.ended {
            if (sender.view?.center.y)! - (self.initialPoint?.y)! > CGFloat(100) {
                self.dismissMenu()
            }
            else {
                UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    sender.view?.center = self.initialPoint!
                }, completion: nil)
                
            }
        }
        
    }
    
    func removeSubviews(){
        for subview in containerView!.subviews {
            subview.removeFromSuperview()
        }
    }
    
}

// Utils

extension UILabel {
    
    func addCharactersSpacing(_ spacing: CGFloat, text: String) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSKernAttributeName, value: spacing, range: NSMakeRange(0, text.characters.count))
        self.attributedText = attributedString
    }
    
}

extension CALayer {
    
    func addLateralBorder(_ edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer();
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: thickness);
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x: 0, y: self.frame.height - thickness, width: self.frame.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height)
            break
        default:
            break
        }
        
        // Border color
        border.backgroundColor = color.cgColor;
        
        self.addSublayer(border)
    }
    
}

