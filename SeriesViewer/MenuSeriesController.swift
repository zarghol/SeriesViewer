//
//  MenuSeriesController.swift
//  SeriesViewer
//
//  Created by Clément NONN on 26/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Cocoa
import AppKit


class MenuSeriesController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate, NSSplitViewDelegate {
    
    @IBOutlet weak var contentView: NSView!
    @IBOutlet weak var outlineView: NSOutlineView!
    var contentController : NSViewController?
    var series: [HeaderItem] = [HeaderItem(nom: "A voir"), HeaderItem(nom: "Séries Actives"), HeaderItem(nom: "Séries Archivées")]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.recupereSeries()
        
        self.changeContentViewWithSelection(0)
        
        self.view.registerForDraggedTypes([NSFilenamesPboardType])
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "fileDragged:", name: NotificationsNames.fichierRecupere.rawValue, object: nil)
    }
    
    override func viewDidAppear() {
        Async.background {
            AccesBetaSerie.acces.checkOnlineToken() { isOK in
                if isOK {
                    let w = self.contentController?.view.frame.width ?? 300
                    let h = w * 720 / 1280
                    let size = CGSize(width: w, height: h)
                    AccesBetaSerie.acces.retrieveSeries(size) {
                        self.recupereSeries()
                    }
                } else {
                    Async.main {
                        self.performSegueWithIdentifier("loginSegue", sender: self)
                    }
                }
            }
        }
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if let it = item as? MenuItem {
            return it.items[index]
        } else {
            return self.series[index]
        }        
    }
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        
        if let it = item as? MenuItem {
            return it.items.count
        } else {
            return self.series.count
        }
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        let it = item as! MenuItem
        return it.items.count > 0
    }
    
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        let it = item as! MenuItem
        
        var view = outlineView.makeViewWithIdentifier(it.cellIdentifier, owner:self) as! NSTableCellView
        view.textField?.stringValue = it.nomItem
        
        return view
    }
    
    func outlineViewSelectionDidChange(notification: NSNotification) {
        if self.outlineView.selectedRow != -1 {
            self.changeContentViewWithSelection(self.outlineView.selectedRow)
        }
    }
    
    func changeContentViewWithSelection(selectedIndex: Int) {
        let item = self.outlineView.itemAtRow(selectedIndex) as! MenuItem
        
        if item is Saison {
            return
        }
        self.contentController?.view.removeFromSuperview()
        println("selectedIndex : \(selectedIndex)")
        switch item {
            case is Serie:
                var viewController = SerieContentViewController()
                viewController?.serie = item as! Serie
                self.contentController = viewController
            
            case is Episode:
                var viewController = EpisodeViewController()
                viewController?.episode = item as! Episode
                self.contentController = viewController
            
            default:
                self.contentController = DefaultContentViewController()
        }
        
        var frame = self.contentView.bounds
        self.contentController!.view.frame = frame
        self.contentController!.view.autoresizingMask = NSAutoresizingMaskOptions.ViewHeightSizable | NSAutoresizingMaskOptions.ViewWidthSizable

        self.contentView.addSubview(self.contentController!.view)
    }
    
    func rechargeAffichage() {
        Async.main {
            self.outlineView.reloadData()
            self.outlineView.sizeLastColumnToFit()
            self.outlineView.floatsGroupRows = false
        }
    }
    
    func fileDragged(notification: NSNotification) {
        if let urls = notification.userInfo?["urls"] as? [String] {
            for urlstring in urls {
                let url = NSURL(fileURLWithPath: urlstring)!
                if contains(["avi", "mp4", "mkv"], url.pathExtension!) {
                    NSLog("type supported")
                    AccesBetaSerie.acces.correspondFilename(url)
                } else {
                    NSLog("type not supported")
                }
            }
        }
    }
    
    
    func recupereSeries() {
        self.series[0].viderSeries()
        self.series[1].viderSeries()
        self.series[2].viderSeries()
        for serie in Persistance.acces.series {
            Async.main {
                if serie.active == true && !serie.toutVue {
                    self.series[0].ajouterSerie(serie)
                }
                self.series[serie.active == true ? 1 : 2].ajouterSerie(serie)
                self.outlineView.reloadData()
            }
        }
    }
    
    func afficheDemandeMembre() {
        NSLog("afficheDemande")
        self.performSegueWithIdentifier("loginSegue", sender: self)
    }
    
    func splitView(splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        return false
    }

}
