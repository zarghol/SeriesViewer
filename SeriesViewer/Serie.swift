//
//  Serie.swift
//  SeriesViewer
//
//  Created by Clément NONN on 26/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Cocoa

enum StatutSeries: String {
    case Ended = "Ended"
    case Autre = "Autre"
    case Continuing = "Continuing"
}

class Serie : NSObject, NSCoding, NSCopying, Equatable, MenuItem {
    
    var nomSerie: String
    var saisons: [Saison]
    
    var nomItem: String {
        return self.nomSerie
    }
    
    var items: [AnyObject] {
        return self.saisons
    }
    
    var cellIdentifier: String {
        return "SerieCell"
    }
    
    var id: Int
    var banner: NSImage?
    var descriptionSerie: String
    var dureeEpisode: Int // en Minutes
    var genres: [String]
    var id_thetvdb: Int

    var status: StatutSeries
    var anneeCreation: Int

    var active: Bool
    
    
    var toutVue:Bool {
        for episode in self.episodes() {
            if !episode.vue && episode.date != nil && episode.date!.compare(NSDate()) == NSComparisonResult.OrderedAscending {
                return false
            }
        }
        return true
    }
    
    
    init(nom: String, active: Bool) {
        self.nomSerie = nom
        self.saisons = [Saison]()
        
        self.id = -1
        self.banner = nil
        self.descriptionSerie = ""
        self.dureeEpisode = 0
        self.genres = [String]()
        self.id_thetvdb = -1
        
        self.status = .Autre
        self.anneeCreation = 0

        self.active = active
    }
    
    init(json: JSON) {
        self.nomSerie = json["title"].stringValue
        self.saisons = [Saison]()
        self.id = json["id"].intValue
        self.descriptionSerie = json["description"].stringValue
        self.dureeEpisode = json["length"].intValue
        self.genres = json["genres"].arrayValue.map{ return $0.stringValue }
        self.id_thetvdb = json["thetvdb_id"].intValue
        
        self.status = StatutSeries(rawValue: json["status"].stringValue) ?? .Autre
        self.anneeCreation = json["creation"].intValue
        
        self.active = !json["user"]["archived"].boolValue
    }
    
    init(serie:Serie) {
        self.nomSerie = serie.nomSerie
        self.saisons = serie.saisons
        self.active = serie.active
        
        self.banner = serie.banner
        self.descriptionSerie = serie.descriptionSerie
        self.dureeEpisode = serie.dureeEpisode
        self.genres = serie.genres
        self.id_thetvdb = serie.id_thetvdb
        self.id = serie.id
        self.status = serie.status
        self.anneeCreation = serie.anneeCreation
        
    }
    
    required init(coder aDecoder: NSCoder) {
        self.nomSerie = (aDecoder.decodeObjectForKey("nomSerie") as? String) ?? ""
        self.saisons = (aDecoder.decodeObjectForKey("saisons") as? [Saison]) ?? [Saison]()
        self.active = aDecoder.decodeBoolForKey("active")
        
        self.banner = aDecoder.decodeObjectForKey("banner") as? NSImage
        self.descriptionSerie = (aDecoder.decodeObjectForKey("descriptionSerie") as? String) ?? ""
        self.dureeEpisode = aDecoder.decodeIntegerForKey("dureeEpisode")
        self.genres = (aDecoder.decodeObjectForKey("genres") as? [String]) ?? [String]()
        self.id_thetvdb = aDecoder.decodeIntegerForKey("id_thetvdb")
        self.id = aDecoder.decodeIntegerForKey("id")
        if let statusText = aDecoder.decodeObjectForKey("status") as? String {
            self.status = StatutSeries(rawValue: statusText)!
        } else {
            self.status = .Autre
        }
        self.anneeCreation = aDecoder.decodeIntegerForKey("anneeCreation")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.nomSerie, forKey: "nomSerie")
        aCoder.encodeObject(self.saisons, forKey: "saisons")
        aCoder.encodeBool(self.active, forKey: "active")
        aCoder.encodeObject(self.banner, forKey: "banner")
        aCoder.encodeObject(self.descriptionSerie, forKey: "descriptionSerie")
        aCoder.encodeInteger(self.dureeEpisode, forKey: "dureeEpisode")
        aCoder.encodeObject(self.genres, forKey: "genres")
        aCoder.encodeInteger(self.id_thetvdb, forKey: "id_thetvdb")
        aCoder.encodeInteger(self.id, forKey: "id")
        aCoder.encodeObject(self.status.rawValue, forKey: "status")
        aCoder.encodeInteger(self.anneeCreation, forKey: "anneeCreation")
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return Serie(serie:self)
    }
    
    /**
        On effectue le différentielle entre la version en ligne (self) et celle locale (serie)

    */
    func fusion(serie:Serie) {
        let min = (self.saisons.count < serie.saisons.count ? self.saisons.count : serie.saisons.count)
        
        // pour toutes les saisons en commun on met à jour
        for i in 0..<min {
            self.saisons[i].fusion(serie.saisons[i])
        }
        
        // si y a plus de saison localement, (très étrange) on les prend
        if self.saisons.count < serie.saisons.count {
            for i in self.saisons.count..<serie.saisons.count {
                self.ajouteSaison(serie.saisons[i])
            }
        }
    }
    
    func ajouteSaison(saison: Saison) {
        self.saisons.append(saison)
    }
    
     func creerSaison(numSaison: Int) {
        var saisons = self.saisons.filter { return $0.numeroSaison == numSaison }
        if saisons.count == 0 {
            let saison = Saison(numero: numSaison)
            self.saisons.append(saison)
        }
    }
    
    func ajouterEpisode(episode:Episode, aSaison numSaison:Int) {
        var saison = self.trouveOuCreeSaison(numSaison)
        
        saison.ajouteEpisode(episode)
    }
    
    /// trouve une saison existante, ou la créé si besoin
    private func trouveOuCreeSaison(numSaison:Int) -> Saison {
        let array = self.saisons.filter { return $0.numeroSaison == numSaison }
        var saison: Saison
        if array.count > 0 {
            saison = array[0]
        } else {
            saison = Saison(numero: numSaison)
            self.ajouteSaison(saison)
        }
        return saison
    }
    
    func trie() {
        self.saisons.sort{
            return $0.numeroSaison < $1.numeroSaison
        }
    }
    
    func episodes() -> [Episode] {
        var result = [Episode]()
        
        for saison in self.saisons {
            var eps : [Episode] = saison.episodes.map { $0 }
            result.extend(eps)
        }
        return result
    }
}

func ==(s1: Serie, s2: Serie) -> Bool {
    return s1.id == s2.id
}

func !=(s1: Serie, s2: Serie) -> Bool {
    return !(s1 == s2)
}

