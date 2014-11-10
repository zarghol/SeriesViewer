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
        // TODO: - coder cette méthode
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
            if let member = root.objectForKey("member") as? [String: String] {
                if let token = member["token"] {
                    NSNotificationCenter.defaultCenter().postNotificationName("recuperationToken", object: self, userInfo:["token" : token])
                    NSLog("token : \(token)")
                }
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
            if let shows = root.objectForKey("shows") as? NSDictionary {
                for i in 0..<(shows.count > 5 ? 5 : shows.count) {
                    
                    if let show = shows["\(i)"] as? [String: AnyObject] {
                        let nom = show["title"] as String
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
            
            var series = [Serie]()
            var memb: Member?
            if let member = root.objectForKey("member") as? NSDictionary {
                if let shows = member.objectForKey("shows") as? NSDictionary {
                    for show in shows.allValues {
                        let title = show["title"] as String
                        let object: AnyObject = show["archive"] ?? "0"
                        let active =  object as NSString  == "0"
                        let url = show["url"] as String
                        series.append(Serie(nom: title, active: active, url: url))
                    }
                }
                let login = member.objectForKey("login") as String
                let avatarUrl = member.objectForKey("avatar") as String
                var badges = 0
                var episodes = 0
                var progress: Float = 0.0
                var seasons = 0
                var shows = 0
                if let stats = member.objectForKey("stats") as? NSDictionary {
                    badges = (stats.objectForKey("badges") as NSNumber).integerValue
                    episodes = (stats.objectForKey("episodes") as NSNumber).integerValue
                    //progress = (stats.objectForKey("progress") as NSNumber).floatValue
                    seasons = (stats.objectForKey("seasons") as NSNumber).integerValue
                    shows = (stats.objectForKey("shows") as NSNumber).integerValue

                }
                memb = Member(login: login, nbBadges: badges, nbEpisodes: episodes, progress: progress, seasons: seasons, nbShows: shows)
                
            }
            let userInfo : [String: NSObject] = ["series" : series]
            NSNotificationCenter.defaultCenter().postNotificationName("resultatMembre", object: self, userInfo:userInfo)

        }, handleError:self.didFail)
    }
    
    
    func isActiveToken() {
        var request = BSRequest()
        request.apiKey = self.apiKey
        request.token = self.token
        request.category = BSRequestCategory.Members
        request.method = BSRequestMethod.IsActive
        request.send(completionHandler: { root in
                                    
            if let token = root.objectForKey("token") as? String {
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
    
//    func request(request: BSRequest, didReceivedDatas datas:NSDictionary) {
//        NSLog("infos recue : \(datas)")
//        
//        let root = datas.objectForKey("root") as NSDictionary
//        switch (request.category, request.method) {
//            
//            case (BSRequestCategory.Members, BSRequestMethod.Auth):
//                if let member = root.objectForKey("member") as? [String: String] {
//                    if let token = member["token"] {
//                        NSNotificationCenter.defaultCenter().postNotificationName("recuperationToken", object: self, userInfo:["token" : token])
//                        NSLog("token : \(token)")
//                    }
//                }
//                
//            case (BSRequestCategory.Members, BSRequestMethod.IsActive):
//                if let token = root.objectForKey("token") as? String {
//                    let valeur = "\(token == self.token)"
//                    NSNotificationCenter.defaultCenter().postNotificationName("tokenActive", object: self, userInfo:["tokenValable" : valeur])
//                    NSLog("token valide : \(valeur)")
//                }
//                
//            case (BSRequestCategory.Shows, BSRequestMethod.Search):
//                var noms = [String]()
//                if let shows = root.objectForKey("shows") as? NSDictionary {
//                    for i in 0..<(shows.count > 5 ? 5 : shows.count) {
//                        
//                        if let show = shows["\(i)"] as? [String: AnyObject] {
//                            let nom = show["title"] as String
//                            noms.append(nom)
//                        }
//                    }
//                }
//                NSNotificationCenter.defaultCenter().postNotificationName("resultatRecherche", object: self, userInfo:["mots" : noms])
//            
//            case (BSRequestCategory.Members, BSRequestMethod.Infos):
//                var noms = [String]()
//                if let member = root.objectForKey("member") as? NSDictionary {
//                    if let shows = member.objectForKey("shows") as? NSDictionary {
//                        for show in shows.allValues {
//                            noms.append(show["title"] as String)
//                        }
//                    }
//                }
//                NSNotificationCenter.defaultCenter().postNotificationName("resultatMembre", object: self, userInfo:["nomSeries" : noms])
//            
//            
//            case (_, _):
//                NSLog("rien a faire")
//        }
//    }

    
    
}