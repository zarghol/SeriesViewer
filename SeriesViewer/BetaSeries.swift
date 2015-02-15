//
//  BetaSerie.swift
//  SeriesViewer
//
//  Created by Clément NONN on 27/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Foundation

let betaseries_user_agent = "Swift BetaSeries Library - ClemNonn (1.0)"
let betaseries_version_api = "2.4"

class BetaSeries {
    private let session: NSURLSession
    private var apiKey: String
    private let token: String?
    
    init(token: String? = nil) {
        self.apiKey = "e88a334499a9"
        self.token = token
        
        let conf = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        var dico: [NSObject : AnyObject] = ["User-Agent" : betaseries_user_agent,
                                            "X-BetaSeries-Key" : self.apiKey,
                                            "X-BetaSeries-Version" : betaseries_version_api]
        
        if let token = self.token {
            dico["X-BetaSeries-Token"] = token
        }
        
        conf.HTTPAdditionalHeaders = dico
        
        self.session = NSURLSession(configuration:conf)
    }
    
    func login(username: String, password:String, completion: (Member) -> (), handleError: (NSError) -> ()) {
        self.login(username, passwordMD5: password.MD5String, completion: completion, handleError:handleError)
    }
    
    func login(username: String, passwordMD5: String, completion: (Member) -> (), handleError: (NSError) -> ()) {
        var request = self.buildRequest(.Members, .Auth, .Post)
        request.addOption(username, forName:"login")
        request.addOption(passwordMD5, forName:"password")
        
        request.send(completionHandler:{ json in
            if let token = json["token"].string {
                var member = Member(token: token)
                completion(member)
            }
        }, handleError: handleError)
    }
    
    func createAccount(username: String, password: String, email:String, completion: (Member) -> ()) {
        var request = self.buildRequest(.Members, .SignUp, .Post)
        request.addOption(username, forName: "login")
        request.addOption(password.MD5String, forName: "password")
        request.addOption(email, forName: "email")
        
        request.send(completionHandler: {json in
            if let token = json["token"].string {
                var member = Member(token: token)
                completion(member)
            }
        }, handleError:self.didFail)
    }
    
    func destroyToken() {
        var request = self.buildRequest(.Members, .Destroy, .Post)
        // envoyer notification pour notifier de la déconnexion coté serveur ?
        request.send(completionHandler: {_ in }, handleError: self.didFail)
    }
    
    func retrieveMemberInformation(summary: Bool, completion: (JSON) -> ()) {
        var request = self.buildRequest(.Members, .Infos)
        if summary {
            request.addOption("true", forName: "summary")
        }
        request.send(completionHandler: {json in
            completion(json)
            // on envoi directement le json
        }, handleError: self.didFail)
    }
    
    func retrieveListSeries(bannerDimension: CGSize, completion: ([Serie]) -> ()) {
        var request = self.buildRequest(.Members, .Infos)
        
        request.send(completionHandler: { root in
            let series: [Serie] = root["member"]["shows"].arrayValue.map {
                var serie = Serie(json: $0)
                self.retrieveBannerAndEpisodes(serie, bannerDimension: bannerDimension)
                return serie
            }
            completion(series)
            
        }, handleError:self.didFail)
    }
    
    func retrieveBannerAndEpisodes(var serie: Serie, bannerDimension: CGSize) {
        self.retrieveEpisodes(serie)
        self.retrieveBanner(serie, bannerDimension: bannerDimension)
    }
    
    func retrieveBanner(var serie: Serie, bannerDimension: CGSize) {
        var request = self.buildRequest(.Pictures, .Shows)
        request.addOption(String(serie.id), forName: "id")
        request.addOption("picked", forName: "banner")
        request.addOption("\(Int(bannerDimension.height))", forName: "height")
        request.addOption("\(Int(bannerDimension.width))", forName: "width")

        
        request.retrieveImage{ image in
            NSLog("recupImage")
            serie.banner = image
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationsNames.banniereRecupere.rawValue, object: nil, userInfo: ["serie" : serie])
        }
    }
    
    func retrieveEpisodes(var serie: Serie) {
        if serie.saisons.count > 0 {
            serie.saisons.removeAll()
        }
        var request = self.buildRequest(.Shows, .Episodes)
        request.addOption(String(serie.id), forName: "id")
        
        var js = JSON(2)
        js.arrayValue

        
        request.send(completionHandler: { root in
            for episodeJson in root["episodes"].arrayValue {
                var episode = Episode(json: episodeJson)
                serie.ajouterEpisode(episode, aSaison: episodeJson["season"].intValue)
            }
            NSLog("recupEpisodes")

            serie.trie()
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationsNames.episodesRecupere.rawValue, object: nil, userInfo: ["serie" : serie])
        }, handleError:{
            NSLog("erreur de recupEpisode pour : \(serie.nomItem)")
            self.didFail($0)
        })
    }
    
    func searchShow(name:String, completion:([Serie]) -> ()) {
        var request = self.buildRequest(.Shows, .Search)
        request.addOption(name, forName: "title")
        
        request.send(completionHandler: { root in
            
            var series = root["shows"].arrayValue.map {
                return Serie(json: $0)
            }
            completion(series)

        }, handleError: self.didFail)
    }
    
    func markAsWatched(episode: Episode) {
        var request = self.buildRequest(.Episodes, .Watched, (episode.vue ? .Post : .Delete))
        request.addOption(String(episode.id), forName: "id")
        
        request.send(completionHandler: {_ in }, handleError: self.didFail)
    }
    
    func markANote(episode: Episode) {
        var request = self.buildRequest(.Episodes, .Note, .Post)
        request.addOption(String(episode.id), forName: "id")
        request.addOption(String(episode.note), forName: "note")
        
        request.send(completionHandler: {_ in }, handleError: self.didFail)
    }
    
    func addToAccount(serie: Serie, completion: (Bool) -> ()) {
        var request = self.buildRequest(.Shows, .Show, .Post)
        request.addOption(String(serie.id), forName: "id")
        
        request.send(completionHandler: {_ in
            completion(true)
        }, handleError: { error in
            completion(false)
            self.didFail(error)
        })
    }
    
    func archive(serie: Serie) {
        var request = self.buildRequest(.Shows, .Archive, (serie.active ? .Delete : .Post))
        request.addOption(String(serie.id), forName: "id")
        
        request.send(completionHandler: {_ in }, handleError: self.didFail)
    }

    
    func isActiveToken(completion: (Bool) -> ()) {
        var request = self.buildRequest(.Members, .IsActive)
        request.send(completionHandler: { root in
            completion(true)
            NSLog("token valide")
        }, handleError: { error in
            self.didFail(error)
            completion(false)
        })
    }
    
    func scraper(filename: NSURL, completion: (Int, Int) -> ()) {
        var request = self.buildRequest(.Episodes, .Scraper)
        request.addOption(filename.lastPathComponent!, forName: "file")
        
        request.send(completionHandler: {json in
            let episodeId = json["episode"]["id"].intValue
            let serieId = json["episode"]["show"]["id"].intValue
            completion(episodeId, serieId)
        }, handleError: self.didFail)
    }
    
    
    func didFail(error: NSError) {
        NSLog("erreur : \(error)")
    }
    
    private func buildRequest(category: BSRequestCategory, _ method: BSRequestMethod, _ httpMethod: HttpMethod = HttpMethod.Get) -> BSRequest {
        var request = BSRequest(apiKey: self.apiKey, session: self.session)
        
        if let token = self.token {
            request.token = token
        }
        
        request.category = category
        request.method = method
        request.httpMethod = httpMethod
        
        return request
    }
}