//
//  Serie.swift
//  SeriesViewer
//
//  Created by Clément NONN on 26/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Foundation

class Serie : MenuItem{
    //var image: IKImage?
    
    init(nom: String) {
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
        var saison = self.items.filter { let saison = $0 as Saison; return saison.numeroSaison == numSaison }[0] as Saison

        saison.creerEpisode(nomEpisode, description: description)
    }
}