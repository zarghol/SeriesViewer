//
//  Saison.swift
//  SeriesViewer
//
//  Created by Clément NONN on 26/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Foundation

class Saison : NSObject, NSCoding, NSCopying, MenuItem {
    var nomItem: String {
        return "Saison \(self.numeroSaison)"
    }
    
    var items: [AnyObject] {
        return self.episodes
    }
    
    var cellIdentifier: String {
        return "SaisonCell"
    }
    
    var episodes: [Episode]
    
    
    let numeroSaison: Int
    
    init(numero: Int) {
        self.numeroSaison = numero
        self.episodes = [Episode]()
    }
    
    init(saison: Saison) {
        self.numeroSaison = saison.numeroSaison
        self.episodes = saison.episodes
    }
    
    required init(coder aDecoder: NSCoder) {
        self.numeroSaison = aDecoder.decodeIntegerForKey("numeroSaison")
        self.episodes = aDecoder.decodeObjectForKey("episodes") as! [Episode]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(self.numeroSaison, forKey: "numeroSaison")
        aCoder.encodeObject(self.episodes, forKey: "episodes")
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return Saison(saison: self)
    }
    
    func ajouteEpisode(episode: Episode) {
        self.episodes.append(episode)
    }
    
    func trie() {
        self.episodes.sort{ return $0.numEpisode < $1.numEpisode }
    }
    
    func fusion(saison:Saison) {
        let min = saison.episodes.count <= self.episodes.count ? saison.episodes.count : self.episodes.count
        
        for i in 0..<min {
            self.episodes[i].fusion(saison.episodes[i])
        }
        
        // si y a plus d'épisodes localement, (très étrange) on les prend
        if self.episodes.count < saison.episodes.count {
            for i in self.episodes.count..<saison.episodes.count {
                self.ajouteEpisode(saison.episodes[i])
            }
        }
    }
}


func ==(s1: Saison, s2: Saison) -> Bool {
    return s1.numeroSaison == s2.numeroSaison && s1.nomItem == s2.nomItem
}

func !=(s1: Saison, s2: Saison) -> Bool {
    return !(s1 == s2)
}