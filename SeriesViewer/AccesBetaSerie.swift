//
//  Authentication.swift
//  SeriesViewer
//
//  Created by Clément NONN on 27/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Foundation

class AccesBetaSerie : NSObject{
    
    private let cleAPI = ""
    private let betaSerie: BetaSeries
    
    private(set) var member: Member?
    
    internal struct Static {
        static let instance = AccesBetaSerie()
    }
    
    class var acces: AccesBetaSerie {
        return Static.instance
    }
    
    private(set) var token: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("tokenBetaSerie")
        }
        
        set {
            if let tok = newValue {
                NSUserDefaults.standardUserDefaults().setObject(tok, forKey:"tokenBetaSerie")
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("tokenBetaSerie")
            }
        }
    }
    
    var seriesComplete:Int = 0
    
    override init() {
        
        self.betaSerie = BetaSeries(apiKey: self.cleAPI)
        
        super.init()
        
        self.betaSerie.token = self.token ?? ""
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "recuperationToken:", name: "recuperationToken", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "finVerificationToken", name: "tokenActive", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "finRecupereSeries:", name: "resultatMembre", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "finRecupereSerie", name: "serieComplete", object: nil)

    }
    
    func verifieToken() {
        if let token = self.token {
            self.betaSerie.isActiveToken()
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName("afficheDemandeMembre", object: self)
        }
    }
    
    func connexionMembre(identifiant: String, password: String) {
        NSLog("demande de token")
        self.betaSerie.obtainTokenWithUsername(identifiant, password: password)
    }
    
    func recuperationToken(notification: NSNotification) {
        if let token = notification.userInfo?["token"] as? String {
            self.token = token
            self.betaSerie.token = token
            self.recupereSeries()
        }
    }
    
    func deconnexion() {
        self.token = nil
        NSNotificationCenter.defaultCenter().postNotificationName("recuperationSeries", object: self, userInfo:["series" : [Serie]()])
    }
    
    func recupereSeries() {
        NSLog("recupere series")
        self.betaSerie.recupSeries()
    }
    
    
//    func recupereSerieEntiere(serie: Serie) {
//        self.betaSerie.recupSerie(serie)
//    }
    
    func finRecupereSeries(notification: NSNotification) {
        if let member = notification.userInfo?["member"] as? Member {
            println("member stocke !")
            self.member = member
        }
        
        if let series = notification.userInfo?["series"] as? [Serie] {
            self.seriesComplete = series.count
            NSNotificationCenter.defaultCenter().postNotificationName("recuperationSeries", object: self, userInfo:["series" : series])
        }
    }
    
    func finRecupereSerie() {
        if --self.seriesComplete <= 0 {
            // envoi notification signalement mise a jour series
            NSNotificationCenter.defaultCenter().postNotificationName("seriesCompletes", object: self)
        }
    }
    
    func chercheSerie(nom: String) {
        self.betaSerie.searchShow(nom)
    }
    
    
    func marqueVue(episode:Episode) {
        self.betaSerie.markAsWatched(episode)
    }
    

}
