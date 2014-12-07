//
//  BSRequest.swift
//  SeriesViewer
//
//  Created by Clément NONN on 27/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Foundation

let betaseries_api_url = "http://api.betaseries.com/"
let betaseries_user_agent = "Swift BetaSeries Library - ClemNonn (1.0)"

enum BSRequestCategory: String{
    case Comments = "comments"
    case Members = "members"
    case Planning = "planning"
    case Shows = "shows"
    case Subtitles = "subtitles"
    case Timeline = "timeline"
}

enum BSRequestMethod : String {
    case Add = "add"
    case Auth = "auth"
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
    case Search = "search"
    case Show = "show"
    case SignUp = "signup"
    case Watched = "watched"
}

typealias BSRequestObject = String
typealias BSRequestOptions = [String: String]

class BSRequest {
    private var session: NSURLSession
    private var request: NSMutableURLRequest
    
    var apiKey: String
    var token: String
    
    let userAgent: String
    let timeout: NSTimeInterval
    
    var category: BSRequestCategory
    var method: BSRequestMethod
    var object: BSRequestObject?
    var options: BSRequestOptions
    var urlSupp: String?
    
    //var delegate: BSRequestDelegate
    
    init(/*delegate: BSRequestDelegate*/) {
        self.apiKey = ""
        self.token = ""
        
        self.userAgent = betaseries_user_agent
        self.timeout = 20

        self.category = BSRequestCategory.Timeline
        self.method = BSRequestMethod.Home
        self.object = nil
        self.options = [String: String]()

        //self.delegate = delegate
        
        
        self.request = NSMutableURLRequest()
        let conf = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.session = NSURLSession(configuration:conf)
    }
    
    func send(#completionHandler:(JSON) -> (), handleError:(NSError) -> ()) {
        self.request.URL = NSURL(string: self.urlStringForRequest())

        self.request.timeoutInterval = self.timeout
        self.request.setValue(self.userAgent, forHTTPHeaderField: "User-Agent")
        
        let task = self.session.dataTaskWithRequest(self.request) { data, response, error in
            if let err = error {
                NSLog("erreur base")
                //self.delegate.request(self, didFailWithError: err)
                handleError(err)
            } else {
                var error: NSError?
                
                let response = JSON(data: data, error: &error)
                NSLog("url : \(self.urlStringForRequest())")

                //let responseAffiche = NSJSONSerialization.JSONObjectWithData(data, options:.AllowFragments, error: &error) as NSDictionary
                if let err = error {
                    NSLog("url : \(self.urlStringForRequest())")
                    NSLog("erreur json\ndata :\n\(data)")
                    handleError(err)
                } else {
                   //NSLog("infos recue : \(responseAffiche)")

                    let root = response["root"]
                    var error2: NSError?
                    var errorAvere = false
                    
                    let err = root["errors"]["error"]

                    if err != JSON.Null(error2) {
                        errorAvere = true
                        let code = err["code"].integerValue!
                        println("err : \(err)")
                        
                        var nouvelleError = NSError(domain:"BetaSerieError", code:code, userInfo: nil)
                        handleError(nouvelleError)
                    }
                    
                    if !errorAvere {
                        completionHandler(root)
                    }
                }
            }
        }
        task.resume()
        
    }
    
    
    private func urlStringForRequest() -> String {
        return BSRequest.pathForCategory(self.category, method: self.method, object: self.object, options: self.options, apiKey: self.apiKey, token: self.token)
    }
    
    private class func pathForCategory(category: BSRequestCategory, method:BSRequestMethod, object:BSRequestObject?, options:BSRequestOptions, apiKey: String?, token: String?) -> String {
        
        var url_final = "\(betaseries_api_url)\(category.rawValue)/\(method.rawValue)"
        
        if let objet = object {
            url_final += "/\(objet)"
        }
        
        url_final += ".json?"
        
        if let cle = apiKey {
            url_final += "key=\(cle)&"
        }
        
        if let tok = token {
            url_final += "token=\(tok)&"
        }
        
        for (cle, valeur) in options {
            url_final += "\(cle)=\(valeur)&"
        }
        
        return url_final
    }
}

protocol BSRequestDelegate {
    func request(request: BSRequest, didFailWithError error: NSError)
    
    func request(request: BSRequest, didReceivedDatas datas:NSDictionary)
}

