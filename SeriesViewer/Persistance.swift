//
//  Persistance.swift
//  SeriesViewer
//
//  Created by Clément NONN on 26/12/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Foundation

class Persistance {
    
    var series: [Serie] {
        get {
            if let data = NSData(contentsOfURL:self.cheminSerie) {
                if let series = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Serie] {
                    return series
                } else {
                    return [Serie]()
                }
            } else {
                return [Serie]()
            }
        }
        
        set {
            let data = NSKeyedArchiver.archivedDataWithRootObject(newValue)
            data.writeToURL(self.cheminSerie, atomically:true)
        }
    }
    
    
    internal struct Static {
        static let instance = Persistance()
    }
    
    class var acces: Persistance {
        return Static.instance
    }
    
    init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"recupereSeries:", name:"recuperationSeries", object:nil)
    }
    
    
    private var cheminSerie: NSURL {
        return Persistance.fileLocationWithName("series")
    }
    
    private class func fileLocationWithName(name:String) -> NSURL{
        let directories = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains:.UserDomainMask)
        
        let dir = directories[directories.count - 1] as NSURL
        
        return NSURL(string:name, relativeToURL:dir)!
    }
    
    
    
    /// demande un différentiel
    func demandeDifferentiel() {
        AccesBetaSerie.acces.recupereSeries()
    }
    
    /** 
        Vérifie les séries dans la persistance par rapport à celles récupérés par internet, avec prise en compte des modifications si besoin. Au final, sauvegarde les modifs en local
    
        :param: series Les séries récupérées depuis le serveur Betaseries
    */
    func differentielSeries(series: [Serie]) {
        var seriesLocales = self.series
        var nouvelSeries = [Serie]()
        for serieServeur in series {
            // on cherche une correspondance dans la persistance
            let correspondance : [Serie] = seriesLocales.filter { $0.nomItem = serieServeur.nomItem }
            if correspondance.count == 0 {
                nouvelSeries.append(serieServeur)
            } else {
                var corresp = correspondance[0].copy() as Serie
                corresp.differentiel(serieServeur)
                nouvelSeries.append(corresp)
            }
        }
    }
    
    func recupereSeries(notification: NSNotification) {
        if let series = notification.userInfo?["series"] as? [Serie] {
            self.differentielSeries(series)
            NSNotificationCenter.defaultCenter().postNotificationName("finDifferentiel", object: nil)
        }
    }
}