//
//  BSRequestMethod.swift
//  SeriesViewer
//
//  Created by Clément NONN on 02/02/2015.
//  Copyright (c) 2015 Clément NONN. All rights reserved.
//

import Foundation

enum BSRequestMethod : String {
    case Add = "add"
    case Auth = "auth"
    case Archive = "archive"
    case Badges = "badges"
    case Delete = "delete"
    case Destroy = "destroy"
    case Display = "display"
    case Downloaded = "downloaded"
    case Episode = "episode"
    case Episodes = "episodes"
    case Friends = "friends"
    case General = "general"
    case Home = "home"
    case Infos = "infos"
    case IsActive = "is_active"
    case Last = "last"
    case Member = "member"
    case Note = "note"
    case Notifications = "notifications"
    case PostEpisode = "post/episode"
    case PostMember = "post/member"
    case PostShow = "post/show"
    case Recommend = "recommend"
    case Remove = "remove"
    case Scraper = "scraper"
    case Search = "search"
    case Show = "show"
    case Shows = "shows"
    case SignUp = "signup"
    case Watched = "watched"
    case Pictures = "pictures"
}