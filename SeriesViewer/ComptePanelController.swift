//
//  CompteController.swift
//  SeriesViewer
//
//  Created by Clément NONN on 28/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Cocoa

class ComptePanelController: NSViewController {

    @IBOutlet weak var boutonDeconnexion: NSButton!
    
    
    convenience init?(nibName:String = "ComptePanelView") {
        self.init(nibName: nibName, bundle: nil)
    }
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        if AccesBetaSerie.acces.member?.token == nil {
            self.boutonDeconnexion.enabled = false
        }
    }
    
    @IBAction func cliqueDeconnexion(sender: AnyObject) {
        AccesBetaSerie.acces.memberLogout()
        self.dismissViewController(self)
    }
}
