//
//  BSRequest.swift
//  SeriesViewer
//
//  Created by Clément NONN on 27/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Foundation

let betaseries_api_url = "https://api.betaseries.com/"
let betaseries_user_agent = "Swift BetaSeries Library - ClemNonn (1.0)"

enum BSRequestCategory: String{
    case Comments = "comments"
    case Members = "members"
    case Planning = "planning"
    case Shows = "shows"
    case Episodes = "episodes"
    case Subtitles = "subtitles"
    case Timeline = "timeline"
    // FIXME pas encore fonctionnel
    case Pictures = "pictures"
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
    case Scraper = "scraper"
    case Search = "search"
    case Show = "show"
    case SignUp = "signup"
    case Watched = "watched"
    case Pictures = "pictures"
}

enum HttpMethod: String {
    case Get = "GET"
    case Put = "PUT"
    case Post = "POST"
    case Delete = "DELETE"
}

typealias BSRequestObject = String
typealias BSRequestOptions = [String: String]

class BSRequest {
    private var session: NSURLSession
    //private var request: NSMutableURLRequest
    
    var apiKey: String
    var token: String
    
    private let userAgent: String
    let timeout: NSTimeInterval
    
    var category: BSRequestCategory
    var method: BSRequestMethod
    var object: BSRequestObject?
    var options: BSRequestOptions
    var httpMethod : HttpMethod
    
    init() {
        self.apiKey = ""
        self.token = ""
        
        self.userAgent = betaseries_user_agent
        self.timeout = 20

        self.category = BSRequestCategory.Timeline
        self.method = BSRequestMethod.Home
        self.httpMethod = .Get
        self.object = nil
        self.options = [String: String]()

        //self.delegate = delegate
        
        
        //self.request = NSMutableURLRequest()
        let conf = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.session = NSURLSession(configuration:conf)
    }
    
    func send(#completionHandler:(JSON) -> (), handleError:(NSError) -> ()) {
//        self.request.URL = NSURL(string: self.urlStringForRequest())
//
//        self.request.timeoutInterval = self.timeout
//        self.request.setValue(self.userAgent, forHTTPHeaderField: "User-Agent")
        
        
        
        let task = self.session.dataTaskWithRequest(self.createRequest()) { data, response, error in
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
                    let stringData = NSString(data: data, encoding: NSUTF8StringEncoding)
                    NSLog("url : \(self.urlStringForRequest())\nerreur json\ndata :\n\(stringData)")
                    handleError(err)
                } else {
                   //NSLog("infos recue : \(responseAffiche)")

                    var error2: NSError?
                    
                    let err = response["errors"]["error"]

                    if err != JSON.Null(error2) {
                        let code = err["code"].integerValue!
                        println("err : \(err)")
                        
                        var nouvelleError = NSError(domain:"BetaSerieError", code:code, userInfo: nil)
                        handleError(nouvelleError)
                    } else {
                        completionHandler(response)
                    }
                }
            }
        }
        task.resume()
    }
    
    private func createRequest() -> NSURLRequest {
        var request = NSMutableURLRequest()
        request.URL = NSURL(string: self.urlStringForRequest())
        request.timeoutInterval = self.timeout
        request.HTTPMethod = self.httpMethod.rawValue
        request.setValue(self.userAgent, forHTTPHeaderField: "User-Agent")

        request.setValue(self.apiKey, forHTTPHeaderField: "X-BetaSeries-Key")
        
        request.setValue("2.3", forHTTPHeaderField:"X-BetaSeries-Version")
        
        if token != "" {
            request.setValue(self.token, forHTTPHeaderField:"X-BetaSeries-Token")
        }
        
        return request
    }
    
    
    
    
    private func urlStringForRequest() -> String {
        var url_final = "\(betaseries_api_url)\(self.category.rawValue)/\(self.method.rawValue)"
        
        if let objet = object {
            url_final += "/\(objet)"
        }
        
        //url_final += ".json" //?key=\(self.apiKey)&"
//
//        if token != "" {
//            url_final += "token=\(self.token)&"
//        }
        
        if options.count > 0 {
            url_final += "?"
        }
    
        for (cle, valeur) in options {
            url_final += "\(cle)=\(valeur)&"
        }
        
//        url_final += "v=2.3"
        
        return url_final

    }
}

protocol BSRequestDelegate {
    func request(request: BSRequest, didFailWithError error: NSError)
    
    func request(request: BSRequest, didReceivedDatas datas:NSDictionary)
}

