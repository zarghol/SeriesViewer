//
//  Persistance.swift
//  SeriesViewer
//
//  Created by Clément NONN on 26/12/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Cocoa

class Persistance: NSObject {
    
    var token: String? {
        get {
            let val = NSUserDefaults.standardUserDefaults().stringForKey("token")
            return val
        }
        
        set {
            if let val = newValue {
                NSUserDefaults.standardUserDefaults().setObject(val, forKey: "token")
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("token")
            }
        }
    }
    
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
    
    private var seriesTemp : [Serie : Bool]
    private var compte : Int
    
    
    internal struct Static {
        static let instance = Persistance()
    }
    
    class var acces: Persistance {
        return Static.instance
    }
    
    override init() {
        self.seriesTemp = [Serie : Bool]()
        self.compte = 0
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"recupIncompletes:", name:NotificationsNames.banniereRecupere.rawValue, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"recupIncompletes:", name:NotificationsNames.episodesRecupere.rawValue, object:nil)
    }
    
    
    private var cheminSerie: NSURL {
        return Persistance.fileLocationWithName("series")
    }
    
    private class func fileLocationWithName(name:String) -> NSURL{
        let directories = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains:.UserDomainMask)
        let dir = directories[directories.endIndex.predecessor()] as! NSURL
        
        return NSURL(string:name, relativeToURL:dir)!
    }
    
    /** 
        Vérifie les séries dans la persistance par rapport à celles récupérés par internet, avec prise en compte des modifications si besoin. Au final, sauvegarde les modifs en local
    
        :param: series Les séries récupérées depuis le serveur Betaseries
    */
    func fusionSeries(series: [Serie]) {
        var nouvelSeries = [Serie]()
        for serieServeur in series {
            // on cherche une correspondance dans la persistance
            let correspondance = self.series.filter { $0.id == serieServeur.id }
            if correspondance.count > 0 {
                if let corr = correspondance[0].copy() as? Serie{
                    serieServeur.fusion(corr)
                }
            }
            nouvelSeries.append(serieServeur)
        }
        self.series = nouvelSeries
        self.seriesTemp.removeAll()
    }
    
    func recupIncompletes(notification: NSNotification) {
        if let serie = notification.userInfo?["serie"] as? Serie {
            self.seriesTemp.updateValue(serie.banner != nil && serie.saisons.count > 0, forKey: serie)
        }
        
        if testOK() {
            self.recupereSeries()
        }
    }
    
    func testOK() -> Bool {
        return self.seriesTemp.values.array.reduce(true, combine: { $0 && $1 })
    }
    
    func recupereSeries() {
        self.fusionSeries(self.seriesTemp.keys.array)
    }
    
    func initTemp(series: [Serie]) {
        series.map { self.seriesTemp[$0] = false }
    }
    
    func addLink(link: NSURL, toEpisode episodeId:Int, inSerie serieId:Int) {
        var seriesActuelles = self.series
        var serie = seriesActuelles.filter { $0.id == serieId }
        if serie.count > 0 {
            var episode = serie[0].episodes().filter { $0.id == episodeId }
            if episode.count > 0 {
                episode[0].lien = link
            }
        }
    }
    
    func majEpisode(episode: Episode) {
        var seriesActuelles = self.series
        for serie in seriesActuelles {
            for saison in serie.saisons {
                var eps = saison.episodes.filter { $0.id == episode.id }
                if eps.count > 0 {
                    eps[0].fusion(episode)
                    break
                }
            }
            
        }
        NSLog("maj dans persistance Episode")
        self.series = seriesActuelles
    }
}