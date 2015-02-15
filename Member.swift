//
//  Member.swift
//  SeriesViewer
//
//  Created by Clément NONN on 10/11/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Cocoa

class Member : NSObject {    
    private(set) var token: String
    
    private(set) var login: String?
    private(set) var avatar: NSImage?
    private(set) var nbBadges: Int?
    private(set) var nbEpisodes: Int?
    private(set) var progress: Float?
    private(set) var seasons: Int?
    private(set) var nbShows: Int?
    
    init(token: String) {
        self.token = token
    }
    
    func retrieveInformation(json : JSON) {
        self.login = json["login"].stringValue
        
        self.nbBadges = json["stats"]["badges"].intValue
        self.nbEpisodes = json["stats"]["episodes"].intValue
        self.progress = json["stats"]["progress"].floatValue
        self.seasons = json["stats"]["seasons"].intValue
        self.nbShows = json["stats"]["shows"].intValue
    }
}