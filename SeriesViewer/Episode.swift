//
//  Episode.swift
//  SeriesViewer
//
//  Created by Clément NONN on 26/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Foundation

class Episode : NSObject, NSCoding, NSCopying, MenuItem {
    let numEpisode: Int
    let descriptionEpisode: String

    let nomEpisode: String
    var note: Int
    let id: Int
    let date: NSDate?
    
    var vue: Bool {
        didSet {
            if oldValue != vue {
                AccesBetaSerie.acces.markAsWatched(self)
            }
        }
    }
    
    // lien du fichier sur le disque
    var lien: NSURL? {
        didSet {
            if self.didSetOk {
                NSLog("majLien")
                Persistance.acces.majEpisode(self)
            }
        }
    }

    var nomItem: String {
        return self.nomEpisode
    }
    
    var cellIdentifier: String {
        return "EpisodeCell"
    }
    
    var items: [AnyObject] {
        return [AnyObject]()
    }
    
    private var didSetOk: Bool
    
    init(nom: String, numEpisode: Int, id: Int, vue:Bool, description: String = "") {
        self.nomEpisode = nom
        self.descriptionEpisode = description
        self.numEpisode = numEpisode
        self.id = id
        self.vue = vue
        self.didSetOk = true
        self.note = 0
        self.date = nil
        
        self.didSetOk = true
    }
    
    init(json: JSON) {
        self.nomEpisode = json["title"].stringValue
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.date = formatter.dateFromString(json["date"].stringValue)
        self.descriptionEpisode = json["description"].stringValue
        self.numEpisode = json["episode"].intValue
        self.id = json["id"].intValue
        self.vue = json["user"]["seen"].boolValue
        self.note = json["note"]["user"].intValue
        
        self.didSetOk = true

    }
    
    required init(coder aDecoder: NSCoder) {
        self.nomEpisode = aDecoder.decodeObjectForKey("nomEpisode") as! String
        self.note = aDecoder.decodeIntegerForKey("note")
        self.date = aDecoder.decodeObjectForKey("date") as? NSDate
        self.descriptionEpisode = aDecoder.decodeObjectForKey("descriptionEpisode") as! String
        self.numEpisode = aDecoder.decodeIntegerForKey("numEpisode")
        self.id = aDecoder.decodeIntegerForKey("id")
        self.vue = aDecoder.decodeBoolForKey("vue")
        self.lien = aDecoder.decodeObjectForKey("lien") as? NSURL
        if let li = self.lien {
            NSLog("décodé : \(li)")
        }
        self.didSetOk = true
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.nomEpisode, forKey: "nomEpisode")
        aCoder.encodeInteger(self.note, forKey: "note")
        aCoder.encodeObject(self.date, forKey: "date")
        aCoder.encodeObject(self.descriptionEpisode, forKey: "descriptionEpisode")
        aCoder.encodeInteger(self.numEpisode, forKey: "numEpisode")
        aCoder.encodeInteger(self.id, forKey: "id")
        aCoder.encodeBool(self.vue, forKey: "vue")
        aCoder.encodeObject(self.lien, forKey: "lien")
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        var res = Episode(nom: self.nomItem, numEpisode: self.numEpisode, id: self.id, vue: self.vue, description: self.descriptionEpisode)
        res.didSetOk = false
        res.lien = self.lien
        res.didSetOk = true
        return res
    }
    
    func fusion(episode: Episode) {
        self.didSetOk = false
        self.lien = episode.lien
        self.didSetOk = true
    }
}