//
//  Serie.swift
//  SeriesViewer
//
//  Created by Clément NONN on 26/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Foundation

enum StatutSeries: String {
    case Ended = "Ended"
    case Autre = "Autre"
    case Continuing = "Continuing"
}

class Serie : MenuItem, NSCoding, NSCopying {
    var active: Bool
    var url: String
    
    var id: Int
    
    var banner: String?
    var descriptionSerie: String
    var dureeEpisode: Int // en Minutes
    var genres: [String]
    var id_thetvdb: Int
    var status: StatutSeries
    var anneeCreation: Int
    // note
    
    
    //var image: IKImage?
    
    init(nom: String, active: Bool, url: String) {
        self.active = active
        self.url = url
        
        self.banner = nil
        self.descriptionSerie = ""
        self.dureeEpisode = 0
        self.genres = [String]()
        self.id_thetvdb = -1
        self.id = -1
        self.status = .Autre
        self.anneeCreation = 0
        
        
        super.init(nom: nom, items: [Saison]())
    }
    
    init(serie:Serie) {
        self.active = serie.active
        self.url = serie.url
        
        self.banner = serie.banner
        self.descriptionSerie = serie.descriptionSerie
        self.dureeEpisode = serie.dureeEpisode
        self.genres = serie.genres
        self.id_thetvdb = serie.id_thetvdb
        self.id = serie.id
        self.status = serie.status
        self.anneeCreation = serie.anneeCreation
        
        super.init(nom: serie.nomItem, items: serie.items)
    }
    
    required init(coder aDecoder: NSCoder) {
        self.active = aDecoder.decodeBoolForKey("active")
        self.url = aDecoder.decodeObjectForKey("url") as String
        
        self.banner = aDecoder.decodeObjectForKey("banner") as String?
        self.descriptionSerie = aDecoder.decodeObjectForKey("descriptionSerie") as String
        self.dureeEpisode = aDecoder.decodeIntegerForKey("dureeEpisode")
        self.genres = aDecoder.decodeObjectForKey("genres") as [String]
        self.id_thetvdb = aDecoder.decodeIntegerForKey("id_thetvdb")
        self.id = aDecoder.decodeIntegerForKey("id")
        self.status = StatutSeries(rawValue: aDecoder.decodeObjectForKey("status") as String)!
        self.anneeCreation = aDecoder.decodeIntegerForKey("anneeCreation")
        super.init(coder: aDecoder)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeBool(self.active, forKey: "active")
        aCoder.encodeObject(self.url, forKey: "url")
        aCoder.encodeObject(self.banner, forKey: "banner")
        aCoder.encodeObject(self.descriptionSerie, forKey: "descriptionSerie")
        aCoder.encodeInteger(self.dureeEpisode, forKey: "dureeEpisode")
        aCoder.encodeObject(self.genres, forKey: "genres")
        aCoder.encodeInteger(self.id_thetvdb, forKey: "id_thetvdb")
        aCoder.encodeInteger(self.id, forKey: "id")
        aCoder.encodeObject(self.status.rawValue, forKey: "status")
        aCoder.encodeInteger(self.anneeCreation, forKey: "anneeCreation")
        super.encodeWithCoder(aCoder)
    }
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        return Serie(serie:self)
    }
    
    func differentiel(serie:Serie) {
        fatalError("unimplementedMethod")
        // TODO fini cette méthode
    }
    
    
    
    func ajouteSaison(saison: Saison) {
        self.items.append(saison)
    }
    
     func creerSaison(numSaison: Int, nomSaison: String = "") {
        var saisons = self.items.filter { let saison = $0 as Saison; return saison.numeroSaison == numSaison }
        if saisons.count == 0 {
            let saison = Saison(numero: numSaison, nomSaison: nomSaison)
            self.items.append(saison)
        }
    }
    
    func ajouterEpisode(nomEpisode: String, description: String, numEpisode: Int, id: Int, vue: Bool, aSaison numSaison: Int) {
        var saison = self.trouveOuCreeSaison(numSaison)

        saison.creerEpisode(nomEpisode, description: description, numEpisode: numEpisode, id: id, vue: vue)
    }
    
    func ajouterEpisode(episode:Episode, aSaison numSaison:Int) {
        var saison = self.trouveOuCreeSaison(numSaison)
        
        saison.ajouteEpisode(episode)
    }
    
    /// trouve une saison existante, ou la créé si besoin
    private func trouveOuCreeSaison(numSaison:Int) -> Saison {
        let array = self.items.filter { return ($0 as Saison).numeroSaison == numSaison }
        var saison : Saison
        if array.count > 0 {
            saison = array[0] as Saison
        } else {
            saison = Saison(numero: numSaison)
            self.ajouteSaison(saison)
        }
        return saison
    }
    
    override func trie() {
        self.items.sort{
            return ($0 as Saison).numeroSaison < ($1 as Saison).numeroSaison
        }
        super.trie()
    }
}