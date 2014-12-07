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

class Serie : MenuItem {
    var active: Bool
    var url: String
    
    var url_banner: String?
    var descriptionSerie: String
    var dureeEpisode: Int // en Minutes
    var genres: [String]
    var id_thetvdb: Int
    var status: StatutSeries
    // note
    
    
    //var image: IKImage?
    
    init(nom: String, active: Bool, url: String) {
        self.active = active
        self.url = url
        
        self.url_banner = nil
        self.descriptionSerie = ""
        self.dureeEpisode = 0
        self.genres = [String]()
        self.id_thetvdb = -1
        self.status = .Autre
        
        
        super.init(nom: nom, items: [Saison]())
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
    
     func ajouterEpisode(nomEpisode: String, description: String, aSaison numSaison:Int) {
        var saison = self.items.filter {return ($0 as Saison).numeroSaison == numSaison }[0] as Saison

        saison.creerEpisode(nomEpisode, description: description)
    }
}