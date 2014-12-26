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
    
    let timeout: NSTimeInterval
    
    init() {
        self.apiKey = ""
        self.token = ""
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
        
        request.send(completionHandler: { root in
            let member = root["member"]
            
            let series: [Serie] = member["shows"].arrayValue!.map { return self.fillSerie($0) }

            
            
            let login = member["login"].stringValue!
            let avatarUrl = member["avatar"].stringValue ?? ""
            var badges = member["stats"]["badges"].integerValue ?? 0
            var episodes = member["stats"]["episodes"].integerValue ?? 0
            var progress: Float = member["stats"]["progress"].floatValue ?? 0.0
            var seasons = member["stats"]["seasons"].integerValue ?? 0
            var showsStats = member["stats"]["shows"].integerValue ?? 0

            var memb = Member(login: login, nbBadges: badges, nbEpisodes: episodes, progress: progress, seasons: seasons, nbShows: showsStats)
            // TODO: envoyer membre
            let userInfo : [String: NSObject] = ["series" : series, "member" : memb]
            NSNotificationCenter.defaultCenter().postNotificationName("resultatMembre", object: self, userInfo:userInfo)

        }, handleError:self.didFail)
    }
    
    private func fillSerie(show:JSON) -> Serie {
        let title = show["title"].stringValue!
        let active = !show["user"]["archived"].boolValue
        let url = show["resource_url"].stringValue!
        
        var serie = Serie(nom: title, active: active, url: url)
        
        serie.id = show["id"].integerValue!
        serie.id_thetvdb = show["thetvdb_id"].integerValue!
        serie.descriptionSerie = show["description"].stringValue!
        serie.anneeCreation = show["creation"].integerValue!
        serie.genres = show["genres"].arrayValue!.map{ return $0.stringValue! }
        serie.status = StatutSeries(rawValue: show["status"].stringValue!)!
        serie.dureeEpisode = show["length"].integerValue!
        
        let nbSaison = show["seasons"].integerValue!
        for i in 1...nbSaison {
            serie.creerSaison(i)
        }
        
        Async.background {
            self.recupBanner(serie)
            self.recupEpisodes(serie)
        }
        
        
        return serie
    }
    
    func recupBanner(var serie: Serie) {
        var request = BSRequest()
        request.apiKey = self.apiKey
        request.token = self.token
        request.category = BSRequestCategory.Shows
        request.method = BSRequestMethod.Pictures
        request.options["id"] = "\(serie.id)"
        
        request.send(completionHandler: { root in
            let pictures = root["pictures"].arrayValue!
            
            for pic in pictures {
                if pic["picked"].stringValue! == "banner" {
                    let url = pic["url"].stringValue!
                    serie.banner = url
                    NSNotificationCenter.defaultCenter().postNotificationName("banniereRecupere", object: self)
                    return
                }
            }
        }, handleError:self.didFail)
    }
    
    func recupEpisodes(var serie: Serie) {
        var request = BSRequest()
        request.apiKey = self.apiKey
        request.token = self.token
        request.category = BSRequestCategory.Shows
        request.method = BSRequestMethod.Episodes
        request.options["id"] = "\(serie.id)"
        
        request.send(completionHandler: { root in
            
            for ep in root["episodes"].arrayValue! {
                let nom = ep["title"].stringValue!
                let description = ep["description"].stringValue!
                let numEpisode = ep["episode"].integerValue!
                let numSaison = ep["season"].integerValue!
                let id = ep["id"].integerValue!
                let watched = ep["user"]["seen"].boolValue
                
                var episode = Episode(nom: nom, numEpisode: numEpisode, id: id, vue: watched, description: description)
                
                serie.ajouterEpisode(episode, aSaison: numSaison)
            }
            
            serie.trie()
            NSNotificationCenter.defaultCenter().postNotificationName("seriesCompletes", object: self)
            }, handleError:{
                NSLog("erreur de recupEpisode pour : \(serie.nomItem)")
                self.didFail($0)
            })
    }
    
    
    func isActiveToken() {
        var request = BSRequest()
        request.apiKey = self.apiKey
        request.token = self.token
        request.category = BSRequestCategory.Members
        request.method = BSRequestMethod.IsActive
        request.send(completionHandler: { root in
            NSNotificationCenter.defaultCenter().postNotificationName("tokenActive", object: self)
            NSLog("token valide")
            }, handleError: { error in
                self.didFail(error)
                NSNotificationCenter.defaultCenter().postNotificationName("afficheDemandeMembre", object: self)
        })
    }
    
    func destroyToken() {
        var request = BSRequest()
        request.apiKey = self.apiKey
        request.token = self.token
        request.category = BSRequestCategory.Members
        request.method = BSRequestMethod.Destroy
        request.send(completionHandler: {_ in }, handleError: self.didFail)
    }
    
    func markAsWatched(episode: Episode) {
        var request = BSRequest()
        request.apiKey = self.apiKey
        request.token = self.token
        request.category = BSRequestCategory.Episodes
        request.method = BSRequestMethod.Watched
        request.options["id"] = "\(episode.id)"
        
        request.send(completionHandler: {_ in }, handleError: self.didFail)
    }
    
    func didFail(error: NSError) {
        NSLog("erreur : \(error)")
    }
}