//
//  BetaSerie.swift
//  SeriesViewer
//
//  Created by Clément NONN on 27/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Foundation

class BetaSeries {
    var apiKey: String
    var token: String
    
    let userAgent: String
    let timeout: NSTimeInterval
    
    init() {
        self.apiKey = ""
        self.token = ""
        self.userAgent = betaseries_user_agent
        self.timeout = 20
    }
    
    convenience init(apiKey:String, token: String = "") {
        self.init()
        self.apiKey = apiKey
        self.token = token
    }
    
    func registerWithUsername(username: String, password: String, email:String) -> [AnyObject]? {
        // TODO: coder cette méthode
        return nil
    }
    
    func obtainTokenWithUsername(username: String, password:String) {
        self.obtainTokenWithUsername(username, passwordMD5: password.MD5String)
    }
    
    func obtainTokenWithUsername(username: String, passwordMD5: String) {
        NSLog("construction de la requete")
        var request = BSRequest()
        request.apiKey = self.apiKey
        request.category = BSRequestCategory.Members
        request.method = BSRequestMethod.Auth
        
        request.options["login"] = username
        request.options["password"] = passwordMD5
        
        request.send(completionHandler:{ root in
            
            if let token = root["member"]["token"].stringValue {
                NSNotificationCenter.defaultCenter().postNotificationName("recuperationToken", object: self, userInfo:["token" : token])
                NSLog("token : \(token)")
            }
        }, handleError: { error in
            NSLog("errorToken")
            if error.code == 4003 {
                NSNotificationCenter.defaultCenter().postNotificationName("mauvaisPassword", object: self)
            }
        })
    }
    
    func searchShow(name:String) {
        //https://api.betaseries.com/shows/search
        
        var request = BSRequest()
        request.apiKey = self.apiKey
        request.token = self.token
        request.category = BSRequestCategory.Shows
        request.method = BSRequestMethod.Search
        
        request.options["title"] = name
        
        request.send(completionHandler: { root in
            
            var noms = [String]()
            
            
            // TODO: revoir si ça marche
            
            
            if let shows = root["shows"].dictionaryValue {
                for i in 0..<(shows.count > 5 ? 5 : shows.count) {
                    
                    if let nom = shows["\(i)"]?["title"].stringValue {
                        noms.append(nom)
                    }
                }
            }
            NSNotificationCenter.defaultCenter().postNotificationName("resultatRecherche", object: self, userInfo:["mots" : noms])
        }, handleError: self.didFail)
    }
    
    func recupSeries() {
        var request = BSRequest()
        request.apiKey = self.apiKey
        request.token = self.token
        request.category = BSRequestCategory.Members
        request.method = BSRequestMethod.Infos
        request.options["summary"] = "true"
        
        request.send(completionHandler: { root in
            
            var series = [Serie]()
            var memb: Member?
            
            let member = root["member"]
            if let shows = member["shows"].dictionaryValue {
                for (_, show) in shows {
                    let title = show["title"].stringValue!
                    let object = show["archive"].integerValue!
                    let active =  object == 0
                    let url = show["url"].stringValue!
                    series.append(Serie(nom: title, active: active, url: url))
                }
            }
            
            let login = member["login"].stringValue!
            let avatarUrl = member["avatar"].stringValue!
            var badges = member["stats"]["badges"].integerValue ?? 0
            var episodes = member["stats"]["episodes"].integerValue ?? 0
            var progress: Float = member["stats"]["progress"].floatValue ?? 0.0
            var seasons = member["stats"]["seasons"].integerValue ?? 0
            var shows = member["stats"]["shows"].integerValue ?? 0

            memb = Member(login: login, nbBadges: badges, nbEpisodes: episodes, progress: progress, seasons: seasons, nbShows: shows)
            // TODO: envoyer membre
            let userInfo : [String: NSObject] = ["series" : series]
            NSNotificationCenter.defaultCenter().postNotificationName("resultatMembre", object: self, userInfo:userInfo)

        }, handleError:self.didFail)
    }
    
    func recupSerie(var serie: Serie) {
        var request = BSRequest()
        request.apiKey = self.apiKey
        request.category = BSRequestCategory.Shows
        request.method = BSRequestMethod.Display
        request.object = serie.url
        
        request.send(completionHandler: { root in
         // TODO récupérer la série
            let show = root["show"]
            serie.url_banner = show["banner"].stringValue!
            serie.descriptionSerie = show["description"].stringValue!
            serie.dureeEpisode = show["duration"].integerValue!
            serie.genres = show["genres"].dictionaryValue!.values.array.map{ return $0.stringValue! }
            serie.id_thetvdb = show["id_thetvdb"].integerValue!
            serie.status = StatutSeries(rawValue: show["status"].stringValue!)!
        }, handleError:self.didFail)
    }
    
    
    func isActiveToken() {
        var request = BSRequest()
        request.apiKey = self.apiKey
        request.token = self.token
        request.category = BSRequestCategory.Members
        request.method = BSRequestMethod.IsActive
        request.send(completionHandler: { root in
                                    
            if let token = root["token"].stringValue {
                let valeur = "\(token == self.token)"
                NSNotificationCenter.defaultCenter().postNotificationName("tokenActive", object: self, userInfo:["tokenValable" : valeur])
                NSLog("token valide : \(valeur)")
            }
        }, handleError: self.didFail)
    }
    
    func destroyToken() {
        var request = BSRequest()
        request.apiKey = self.apiKey
        request.token = self.token
        request.category = BSRequestCategory.Members
        request.method = BSRequestMethod.Destroy
        request.send(completionHandler: {_ in }, handleError: self.didFail)
    }
    
    func didFail(error: NSError) {
        NSLog("erreur : \(error)")
    }
}