//
//  IdentificationController.swift
//  SeriesViewer
//
//  Created by Clément NONN on 27/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Cocoa

class IdentificationController: NSViewController {

    @IBOutlet weak var identifiantTextField: NSTextField!
    @IBOutlet weak var mdptextField: NSSecureTextField!
    
    @IBOutlet weak var labelMauvais: NSTextField!
    
    var frameOriginLabel: NSRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.frameOriginLabel = self.labelMauvais.frame
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"mdpOK", name:"recuperationToken", object:nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"mdpMauvais", name:"mauvaisPassword", object:nil)


    }
    
    @IBAction func annulerAction(sender: AnyObject) {
        self.dismissViewController(self)
    }
    
    @IBAction func envoyerAction(sender: NSButton) {
        // envoyer
        let id = self.identifiantTextField.stringValue
        let mdp = self.mdptextField.stringValue
        AccesBetaSerie.acces.connexionMembre(id, password: mdp)
    }
    
    func mdpMauvais() {
        dispatch_async(dispatch_get_main_queue(), {
            self.labelMauvais.hidden = false
            self.shake(self.labelMauvais)
        })
    }
    
    
    func mdpOK() {
        dispatch_async(dispatch_get_main_queue(), {
            if self.presentedViewControllers?.count > 0 {
                self.dismissViewController(self)
            }
        })
    }
    
    func shake(view: NSView) {
        var directionActuelle = 1
        var shakes = 10
        
        for shake in 1...shakes {
            let animation = self.buildAnimation(view, direction: shake % 2, final: shake == shakes)
            animation.startAnimation()
        }
        
        
        
//        
//        NSView.animateWithDuration(0.03, animations: {
//            view.transform = CGAffineTransformMakeTranslation(5 * directionActuelle, 0)
//        }, completion: { finished in
//            if shakes > 10 {
//                view.transform = CGAffineTransformIdentity;
//                return;
//            }
//            shakes++
//            directionActuelle *= -1
//            self.shake(view)
//        })
    }
    
    func buildAnimation(view:NSView, direction:Int = 1, final: Bool) -> NSViewAnimation {
        let frameBeginning = view.frame
        var frameEnding = frameBeginning
        frameEnding.origin.x =  self.frameOriginLabel.origin.x
        
        if !final {
            frameEnding.origin.x += CGFloat(direction * 5)
        }
        
        var dictionary = NSMutableDictionary()
        dictionary.setObject(view, forKey: NSViewAnimationTargetKey)
        dictionary.setObject(NSValue(rect:frameBeginning), forKey: NSViewAnimationStartFrameKey)
        dictionary.setObject(NSValue(rect:frameEnding), forKey: NSViewAnimationEndFrameKey)
        
        var animation = NSViewAnimation(viewAnimations:[dictionary])
        animation.animationCurve = NSAnimationCurve.EaseIn
        
        return animation
    }
    
    /*
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.5];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[textField animator] setFrameOrigin:NSMakePoint(x,y)];
    [CATransaction commit];
*/
}
