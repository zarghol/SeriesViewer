//
//  WindowController.swift
//  SeriesViewer
//
//  Created by Clément NONN on 28/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Cocoa
import AppKit

class WindowController: NSWindowController, NSToolbarDelegate, NSSplitViewDelegate {
    
    private var panels: [NSViewController]!
    private var actualPanelSelected: Int!

    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.panels = [GeneralPanelController()!, ComptePanelController()!]
        self.actualPanelSelected = 0
        self.contentViewController = self.panels[self.actualPanelSelected]
        
        if let window = self.window, let contentViewController = self.contentViewController {
            contentViewController.view.frame = window.contentView.frame
            window.contentView = contentViewController.view
        }

    }
    
    
    @IBAction func changeOnglet(sender: NSToolbarItem) {
        self.actualPanelSelected = sender.tag - 1
        
        self.contentViewController = self.panels[self.actualPanelSelected]
        if let window = self.window, let contentViewController = self.contentViewController {
            window.contentView = contentViewController.view
        }
    }
}
