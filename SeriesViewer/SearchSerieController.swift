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
                    AccesBetaSerie.acces.searchSeries(chaine) { series in
                        self.mots = series.map { $0.nomSerie }
                    }
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
}
