//
//  MenuSeriesController.swift
//  SeriesViewer
//
//  Created by Clément NONN on 26/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Cocoa
import AppKit


class MenuSeriesController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    @IBOutlet weak var outlineView: NSOutlineView!
    var series: [HeaderItem] = [HeaderItem(nom: "Séries Actives"), HeaderItem(nom: "Séries Archivées")]

    override func viewDidLoad() {
        super.viewDidLoad()
        let serie1 = Serie(nom: "Série Test", active: true, url: "")
        serie1.creerSaison(1)
        serie1.ajouterEpisode("Il était une fois..", description: "", aSaison: 1)
        let serie2 = Serie(nom: "Série 2", active: false, url: "")

        self.recupereSeries([serie1, serie2])
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"recupereSeries:", name:"recuperationSeries", object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"afficheDemandeMembre", name:"afficheDemandeMembre", object:nil)
    }
    
    override func viewDidAppear() {
        NSLog("verif Token")
        AccesBetaSerie.acces.verifieToken()
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
    
    func recupereSeries(notification: NSNotification) {
        if let series = notification.userInfo?["series"] as? [Serie] {
            self.recupereSeries(series)
        }
    }
    
    func recupereSeries(series: [Serie]) {
        self.series[0].viderSeries()
        self.series[1].viderSeries()
        for serie in series {
            dispatch_async(dispatch_get_main_queue()) {
                self.series[serie.active == true ? 0 : 1].ajouterSerie(serie)
                self.outlineView?.reloadData()
            }
        }
    }
    
    func afficheDemandeMembre() {
        NSLog("afficheDemande")
        self.performSegueWithIdentifier("loginSegue", sender: self)
    }
}
