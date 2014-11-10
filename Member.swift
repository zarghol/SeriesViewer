//
//  Member.swift
//  SeriesViewer
//
//  Created by Clément NONN on 10/11/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Cocoa

class Member : NSObject {
    private(set) var avatar: NSImage?
    private(set) var login: String
    private(set) var nbBadges: Int
    private(set) var nbEpisodes: Int
    private(set) var progress: Float
    private(set) var seasons: Int
    private(set) var nbShows: Int
    
    init(login: String, avatar: NSImage? = nil, nbBadges: Int, nbEpisodes: Int, progress: Float, seasons: Int, nbShows: Int) {
        self.login = login
        self.avatar = avatar
        self.nbBadges = nbBadges
        self.nbEpisodes = nbEpisodes
        self.progress = progress
        self.seasons = seasons
        self.nbShows = nbShows
    }
}