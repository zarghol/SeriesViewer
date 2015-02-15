//
//  Authentication.swift
//  SeriesViewer
//
//  Created by Clément NONN on 27/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Foundation

class AccesBetaSerie : NSObject {
    
    private var betaSerie: BetaSeries
    
    private(set) var member: Member? {
        didSet {
            self.betaSerie = BetaSeries(token: self.member?.token)
        }
    }
    private(set) var searchResult: [Serie]?
    
    var series: [Serie] {
        return Persistance.acces.series
    }
    
    internal struct Static {
        static var instance = AccesBetaSerie(token: Persistance.acces.token)
    }
    
    class var acces: AccesBetaSerie {
        get {
            return Static.instance
        }
        
        set {
            Static.instance = newValue
        }
    }
    
    var seriesComplete:Int
    
    init(token: String? = nil) {
        
        self.betaSerie = BetaSeries(token: token)
        self.seriesComplete = 0
        if let tok = token {
            self.member = Member(token: tok)
        }
    }
    
    func accountCreation(login: String, password: String, email: String) {
        self.betaSerie.createAccount(login, password: password, email: email) { member in
            self.member = member
            Persistance.acces.token = member.token

        }
    }
    
    func memberLogin(login: String, password: String, completion: (NSError?) -> ()) {
        self.betaSerie.login(login, password: password, completion: { member in
            self.member = member
            Persistance.acces.token = member.token

            completion(nil)
        }, handleError: { error in
            completion(error)
        })
    }
    
    func getMemberInformation() {
        self.betaSerie.retrieveMemberInformation(true) { json in
            self.member?.retrieveInformation(json)
        }
    }
    
    func retrieveSeries(bannerDimension: CGSize, completion: () -> ()) {
        self.betaSerie.retrieveListSeries(bannerDimension) { series in
            Persistance.acces.initTemp(series)
            completion()
        }
    }
    
    func memberLogout() {
        self.betaSerie.destroyToken()
        self.member = nil
        Persistance.acces.token = nil

    }
    
    func isLoggedIn() -> Bool {
        return self.member != nil && self.member!.token != ""
    }
    
    func searchSeries(text: String, completion: ([Serie]) -> ()) {
        self.searchResult?.removeAll()
        self.betaSerie.searchShow(text) { result in
            self.searchResult = result
            completion(result)
        }
    }
    
    func checkOnlineToken(completion: (Bool) -> ()) {
        self.betaSerie.isActiveToken() { isActive in
            completion(isActive)
        }
    }
    
    func markAsWatched(episode:Episode) {
        self.betaSerie.markAsWatched(episode)
    }
    
    func markANote(episode:Episode) {
        self.betaSerie.markANote(episode)
    }
    
    func archiveSerie(serie:Serie) {
        self.betaSerie.archive(serie)
    }
    
    func addToAccount(serie: Serie) {
        self.betaSerie.addToAccount(serie) { successful in
            if successful {
                Persistance.acces.series.append(serie)
            }
        }
    }
    
    func correspondFilename(url: NSURL) {
        self.betaSerie.scraper(url) { episodeId, serieId in
            NSLog("url : \(url)")
            Persistance.acces.addLink(url, toEpisode: episodeId, inSerie: serieId)
        }
    }
}
