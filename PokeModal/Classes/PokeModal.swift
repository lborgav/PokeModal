//
//  PokeModal.swift
//  PokeModal
//
//  Created by Leonardo Borges Avelino on 8/3/16.
//  Copyright © 2016 Leonardo Borges Avelino. All rights reserved.
//

import Foundation
import UIKit


@objc public protocol PokeModalDelegate {
    optional func pokeModalWillHide()
}

public class PokeModal: UIResponder {
    
    private var containerView: UIView?
    private var buttonImage: UIImage?
    private var titleLabel: UILabel?
    private var contentLabel: UILabel?
    private var closeButton: UIButton?
    private var isShown: Bool? = false
    private var view: UIView?
    private var initialPoint: CGPoint?
    
    public var delegate: PokeModalDelegate?
    
    public var titleText: String = "TITLE" {
        didSet { }
    }
    
    public var contentText: String = "Content" {
        didSet { }
    }
    
    let screenHeight = UIScreen.mainScreen().bounds.height
    let screenWidth = UIScreen.mainScreen().bounds.width
    
    public init(view: UIView) {
        super.init()
        
        self.view = view
        
        containerView = UIView(frame: CGRect(x: 30, y: screenHeight, width: screenWidth - 60
            , height: screenHeight / 2.0))
        containerView?.backgroundColor = UIColor.whiteColor()

        containerView?.layer.borderWidth = 0.0
        containerView?.layer.borderColor = UIColor ( red: 0.2608, green: 0.8168, blue: 0.8177, alpha: 1.0 ).CGColor
        
        containerView?.layer.shadowOffset = CGSizeZero
        containerView?.layer.shadowOpacity = 1
        containerView?.layer.shadowColor = UIColor ( red: 0.6699, green: 0.6941, blue: 0.7486, alpha: 1.0 ).CGColor
        containerView?.layer.shadowRadius = 10
        
        // Dealing with bundles...
        let podBundle = NSBundle(forClass: self.classForCoder)
        if let bundleURL = podBundle.URLForResource("PokeModal", withExtension: "bundle") {
            if let bundle = NSBundle(URL: bundleURL) {
                buttonImage = UIImage(named: "close", inBundle: bundle, compatibleWithTraitCollection: nil)
            }else {
                assertionFailure("Could not load the bundle")
            }
        }else {
            assertionFailure("Could not create a path to the bundle")
        }
        

        
        titleLabel = UILabel(frame: CGRect(x: (screenWidth - 60) / 2.0 - 80, y: 0, width: 160, height: 40))
        titleLabel?.textAlignment = .Center
        titleLabel?.backgroundColor = UIColor.clearColor()
        
        contentLabel = UILabel(frame: CGRect(x: 20, y: 70, width: screenWidth - 60 - 40, height: 80))
        contentLabel?.textAlignment = .Center
        contentLabel?.numberOfLines = 0
        contentLabel?.backgroundColor = UIColor.clearColor()
        
        closeButton = UIButton(frame: CGRect(x: (screenWidth - 60) / 2.0 - 25, y: self.screenHeight / 2.0 - 80, width: 50, height: 50))
        closeButton?.backgroundColor = UIColor.clearColor()
        closeButton?.setBackgroundImage(buttonImage, forState: UIControlState.Normal)
        closeButton?.setTitle("", forState: UIControlState.Normal)
        closeButton?.addTarget(self, action: #selector(PokeModal.dismissMenu), forControlEvents: UIControlEvents.TouchUpInside)
        
        
        let downGesture = UIPanGestureRecognizer(target: self, action: #selector(PokeModal.swipedDown))
        containerView?.addGestureRecognizer(downGesture)
    }
    
    public func showMenu() -> Void {
        if isShown == false {
            
            if closeButton != nil {
                self.containerView?.addSubview(closeButton!)
            }
            
            if titleLabel != nil {
                titleLabel?.font = UIFont(name: "Avenir-Black", size: 15)
                titleLabel?.addCharactersSpacing(3, text: self.titleText)
                titleLabel?.layer.addLateralBorder(UIRectEdge.Bottom, color: UIColor.blackColor(), thickness: 1)
                self.containerView?.addSubview(titleLabel!)
            }
            
            if contentLabel != nil {
                contentLabel?.font = UIFont(name: "Avenir-Book", size: 12)
                contentLabel?.text = self.contentText
                contentLabel?.backgroundColor = UIColor.clearColor()
                self.containerView?.addSubview(contentLabel!)
            }
            
            self.view!.addSubview(self.containerView!)
            self.view!.bringSubviewToFront(self.containerView!)
            
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.containerView?.frame = CGRect(x: 30, y: self.screenHeight / 2.0, width: self.screenWidth - 60, height: self.screenHeight / 2.0)
                }, completion: nil)
            
            
        }
        isShown = true
    }
    
    public func dismissMenu() {
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
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
    
    @objc func swipedDown(sender: UIPanGestureRecognizer) -> Void {
        
        let translation = sender.translationInView(self.view)
        
        if sender.state == UIGestureRecognizerState.Began {
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
        sender.setTranslation(CGPointZero, inView: self.view)
        
        if sender.state == UIGestureRecognizerState.Ended {
            if (sender.view?.center.y)! - (self.initialPoint?.y)! > CGFloat(100) {
                self.dismissMenu()
            }
            else {
                UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
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
    
    func addCharactersSpacing(spacing: CGFloat, text: String) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSKernAttributeName, value: spacing, range: NSMakeRange(0, text.characters.count))
        self.attributedText = attributedString
    }
    
}

extension CALayer {
    
    func addLateralBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer();
        
        switch edge {
        case UIRectEdge.Top:
            border.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), thickness);
            break
        case UIRectEdge.Bottom:
            border.frame = CGRectMake(0, CGRectGetHeight(self.frame) - thickness, CGRectGetWidth(self.frame), thickness)
            break
        case UIRectEdge.Left:
            border.frame = CGRectMake(0, 0, thickness, CGRectGetHeight(self.frame))
            break
        case UIRectEdge.Right:
            border.frame = CGRectMake(CGRectGetWidth(self.frame) - thickness, 0, thickness, CGRectGetHeight(self.frame))
            break
        default:
            break
        }
        
        // Border color
        border.backgroundColor = color.CGColor;
    
        self.addSublayer(border)
    }
    
}

