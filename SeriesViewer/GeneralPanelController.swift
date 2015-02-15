//
//  GeneralPanelController.swift
//  SeriesViewer
//
//  Created by Clément NONN on 14/02/2015.
//  Copyright (c) 2015 Clément NONN. All rights reserved.
//

import Cocoa

class GeneralPanelController: NSViewController {
    
    @IBOutlet var checkCopyFile: NSButton!
    @IBOutlet var importFolderButton: NSButton!
    @IBOutlet var localBiblioPopupButton: NSPopUpButton!
    
    convenience init?(nibName:String = "GeneralPanelView") {
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
    }
    
}
