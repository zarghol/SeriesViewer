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
    var series: [HeaderItem] = [HeaderItem(nom: "Séries Actives"), HeaderItem(nom: "Séries Archivées")]

    override func viewDidLoad() {
        super.viewDidLoad()
        let serie1 = Serie(nom: "Série Test", active: true, url: "")
        //serie1.creerSaison(1)
        serie1.ajouterEpisode("Il était une fois..", description: "", aSaison: 1)
        
        let serie2 = Serie(nom: "Série 2", active: false, url: "")

        self.recupereSeries([serie1, serie2])
        self.changeContentViewWithSelection(0)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"recupereSeries:", name:"recuperationSeries", object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"afficheDemandeMembre", name:"afficheDemandeMembre", object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"seriesCompletes", name:"rechargeAffichage", object:nil)

    }
    
    override func viewDidAppear() {
        Async.background {
            AccesBetaSerie.acces.verifieToken()
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
            return it.nombreEnfant()
        } else {
            return self.series.count
        }
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        let it = item as MenuItem
        return it.nombreEnfant() > 0
    }
    
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        let it = item as MenuItem
        
        var identifier: String
        switch item {
            case is Serie:
                identifier = "SerieCell"
            
            case is Saison:
                identifier = "SaisonCell"
            
            case is Episode:
                identifier = "EpisodeCell"
            
            case is HeaderItem:
                identifier = "HeaderCell"
            
            default:
                identifier = "DataCell"
        }
        
        var view = outlineView.makeViewWithIdentifier(identifier, owner:self) as NSTableCellView
        view.textField?.stringValue = it.nom()
        
        return view
    }
    
    func outlineViewSelectionDidChange(notification: NSNotification) {
        if self.outlineView.selectedRow != -1 {
            self.changeContentViewWithSelection(self.outlineView.selectedRow)
        }
    }
    
    func changeContentViewWithSelection(selectedIndex: Int) {
        let item = self.outlineView.itemAtRow(selectedIndex) as MenuItem
        self.contentController?.view.removeFromSuperview()
        println("selectedIndex : \(selectedIndex)")
        switch item {
            case is Serie:
                var viewController = SerieContentViewController()
                viewController?.serie = item as Serie
                self.contentController = viewController
                
            default:
                self.contentController = DefaultContentViewController()
        }
        
        var frame = self.contentView.bounds
        frame.origin.y -= 65.0
        self.contentController!.view.frame = frame
        self.contentController?.view.autoresizingMask = NSAutoresizingMaskOptions.ViewHeightSizable | NSAutoresizingMaskOptions.ViewWidthSizable
        
        println("outline : \nbounds : \(self.outlineView.bounds)\nframe : \(self.outlineView.frame)\n")
        println("contentView : \nbounds : \(self.contentView.bounds)\nframe : \(self.contentView.frame)\n")
        
        self.contentView.addSubview(self.contentController!.view)
    }
    
    func rechargeAffichage() {
        Async.main {
            self.outlineView.reloadData()
            self.outlineView.sizeLastColumnToFit()
            self.outlineView.floatsGroupRows = false
        }
    }
    
    func recupereSeries(notification: NSNotification) {
        if let series = notification.userInfo?["series"] as? [Serie] {
            self.recupereSeries(series)
        }
    }
    
    func recupereSeries(series: [Serie]) {
        self.series[0].viderSeries()
        self.series[1].viderSeries()
        for serie in series {
            Async.main {
                self.series[serie.active == true ? 0 : 1].ajouterSerie(serie)
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
