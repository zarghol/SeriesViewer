//
//  Saison.swift
//  SeriesViewer
//
//  Created by Clément NONN on 26/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Foundation

class Saison : MenuItem, NSCoding, NSCopying {
    let numeroSaison: Int
    
    init(numero: Int, nomSaison: String = "") {
        self.numeroSaison = numero
        super.init(nom: nomSaison, items: [Episode]())
    }
    
    init(saison: Saison) {
        self.numeroSaison = saison.numeroSaison
        super.init(nom: saison.nomItem, items: saison.items)
    }
    
    required init(coder aDecoder: NSCoder) {
        self.numeroSaison = aDecoder.decodeIntegerForKey("numeroSaison")
        super.init(coder: aDecoder)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(self.numeroSaison, forKey: "numeroSaison")
        super.encodeWithCoder(aCoder)
    }
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        return Saison(saison: self)
    }
    
    override func nom() -> String {
        var nomSaison = "Saison \(self.numeroSaison)"
        if nomItem != "" {
            nomSaison += " : \(self.nomItem)"
        }
        return nomSaison
    }
    
    func ajouteEpisode(episode: Episode) {
        self.items.append(episode)
    }
    
    func creerEpisode(nom: String, description: String, id: Int, vue: Bool) {
        self.creerEpisode(nom, description: description, numEpisode: self.items.count+1, id: id, vue: vue)
    }
    
    func creerEpisode(nom: String, description: String, numEpisode: Int, id: Int, vue: Bool) {
        let episode = Episode(nom: nom, numEpisode: numEpisode, id: id, vue: vue, description: description)
        self.items.append(episode)
    }
    
    override func trie() {
        self.items.sort{ return ($0 as Episode).numEpisode < ($1 as Episode).numEpisode }
    }
}


func ==(s1: Saison, s2: Saison) -> Bool {
    return s1.numeroSaison == s2.numeroSaison && s1.nomItem == s2.nomItem
}

func !=(s1: Saison, s2: Saison) -> Bool {
    return !(s1 == s2)
}