//
//  Saison.swift
//  SeriesViewer
//
//  Created by Clément NONN on 26/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Foundation

class Saison : MenuItem {
    let numeroSaison: Int
    
    init(numero: Int, nomSaison: String = "") {
        self.numeroSaison = numero
        super.init(nom: nomSaison, items: [Episode]())
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
    
    func creerEpisode(nom: String, description: String) {
        let episode = Episode(nom: nom, numEpisode: self.items.count+1, description: description)
        self.items.append(episode)
    }
}

func ==(s1: Saison, s2: Saison) -> Bool {
    return s1.numeroSaison == s2.numeroSaison && s1.nomItem == s2.nomItem
}

func !=(s1: Saison, s2: Saison) -> Bool {
    return !(s1 == s2)
}