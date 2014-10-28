//
//  SearchSerieController.swift
//  SeriesViewer
//
//  Created by Clément NONN on 27/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Cocoa


class SearchSerieController: NSViewController {
    var completePosting: Bool = true
    var mots = [String]()

    @IBOutlet weak var champRecherche: NSSearchField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"prendMots:", name:"resultatRecherche", object:nil)
    }
    
    @IBAction func annulerRecherche(sender: NSButton) {
        self.dismissViewController(self)
    }
    
    @IBAction func ajouterSerie(sender: NSButton) {
        self.dismissViewController(self)
    }
    
    
    override func controlTextDidChange(obj: NSNotification) {
        if let textView = obj.userInfo?["NSFieldEditor"] as? NSTextView {
            NSLog("change text")
            if self.completePosting {
                self.completePosting = false
                textView.complete(nil)
                if let chaine = textView.string {
                    AccesBetaSerie.acces.chercheSerie(chaine)
                }
                self.completePosting = true
            }
            
        }
    }
    
    func control(control: NSControl, textView: NSTextView, completions words: [AnyObject], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>) -> [AnyObject] {
        //let partialString = textView.string().substringWithRange(charRange)
        NSLog("va afficher les mots")
        
        
        let motActuel = textView.string!
        var mots = self.mots
        mots.insert(motActuel, atIndex:0)
        return mots
    }
    
    func prendMots(notification: NSNotification) {
        NSLog("recupereMots")
        if let mots = notification.userInfo?["mots"] as? [String] {
            for mot in mots {
                NSLog(mot)
            }
            self.mots = mots
        }
    }
}
