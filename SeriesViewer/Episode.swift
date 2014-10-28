//
//  Episode.swift
//  SeriesViewer
//
//  Created by Clément NONN on 26/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Foundation

class Episode : MenuItem {
    let descr: String
    let numEpisode: Int
    // let lien
    
    init(nom: String, numEpisode: Int, description: String = "") {
        self.descr = description
        self.numEpisode = numEpisode
        super.init(nom: nom, items: [Episode]())
    }
    
    override func nombreEnfant() -> Int {
        return 0
    }
    
    override func nom() -> String {
        return "\(self.numEpisode) - \(self.nomItem)"
    }
}