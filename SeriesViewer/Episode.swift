//
//  Episode.swift
//  SeriesViewer
//
//  Created by Clément NONN on 26/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Foundation

// TODO PERSISTENCE

class Episode : MenuItem, NSCoding, NSCopying {
    let numEpisode: Int
//    let nomEpisode: String -> nomItem
    let descriptionEpisode: String
    
    var vue: Bool {
        didSet {
            if oldValue != vue {
                AccesBetaSerie.acces.marqueVue(self)
            }
        }
    }
    
    let id: Int
    var lien: NSURL?
    
    init(nom: String, numEpisode: Int, id: Int, vue:Bool, description: String = "") {
        self.descriptionEpisode = description
        self.numEpisode = numEpisode
        self.id = id
        self.vue = vue
        super.init(nom: nom, items: [Episode]())
    }
    
    required init(coder aDecoder: NSCoder) {
        self.descriptionEpisode = aDecoder.decodeObjectForKey("descriptionEpisode") as String
        self.numEpisode = aDecoder.decodeIntegerForKey("numEpisode")
        self.id = aDecoder.decodeIntegerForKey("id")
        self.vue = aDecoder.decodeBoolForKey("vue")
        super.init(coder: aDecoder)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.descriptionEpisode, forKey: "descriptionEpisode")
        aCoder.encodeInteger(self.numEpisode, forKey: "numEpisode")
        aCoder.encodeInteger(self.id, forKey: "id")
        aCoder.encodeBool(self.vue, forKey: "vue")
        super.encodeWithCoder(aCoder)
    }
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        return Episode(nom: self.nomItem, numEpisode: self.numEpisode, id: self.id, vue: self.vue, description: self.descriptionEpisode)
    }
    
    override func nombreEnfant() -> Int {
        return 0
    }
    
    override func nom() -> String {
        return "\(self.numEpisode) - \(self.nomItem)"
    }
}