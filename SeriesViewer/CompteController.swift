//
//  CompteController.swift
//  SeriesViewer
//
//  Created by Clément NONN on 28/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Cocoa

class CompteController: NSViewController {

    @IBOutlet weak var boutonDeconnexion: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        if AccesBetaSerie.acces.token == nil {
            self.boutonDeconnexion.enabled = false
            NSNotificationCenter.defaultCenter().postNotificationName("afficheDemandeMembre", object: self)
        }
    }
    
    @IBAction func cliqueDeconnexion(sender: AnyObject) {
        AccesBetaSerie.acces.deconnexion()
        self.dismissViewController(self)
    }
    
    
    @IBAction func cliqueOK(sender: AnyObject) {
        self.dismissViewController(self)
    }
}
