//
//  BSRequest.swift
//  SeriesViewer
//
//  Created by Clément NONN on 27/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Cocoa

let betaseries_api_url = "https://api.betaseries.com/"

typealias BSRequestObject = String
typealias BSRequestOptions = [String: String]

class BSRequest {
    private var session: NSURLSession
    
    var apiKey: String
    var token: String?
    
    private let userAgent: String
    let timeout: NSTimeInterval
    
    var category: BSRequestCategory
    var method: BSRequestMethod
    var object: BSRequestObject?
    var options: BSRequestOptions
    var httpMethod : HttpMethod
    
    init(apiKey: String, session: NSURLSession) {
        self.apiKey = apiKey
        self.session = session
        
        self.userAgent = betaseries_user_agent
        self.timeout = 20

        self.category = BSRequestCategory.Timeline
        self.method = BSRequestMethod.Home
        self.httpMethod = .Get
        self.object = nil
        self.options = BSRequestOptions()
    }
    
    func send(#completionHandler:(JSON) -> (), handleError:(NSError) -> ()) {
        let task = self.session.dataTaskWithRequest(self.createRequest()) { data, response, error in
            if let err = error {
                NSLog("erreur base")
                handleError(err)
            } else {
                let json = JSON(data: data)

                var error2: NSError?
                
                let errorsjson = json["errors"]
                if errorsjson.count > 0 {
                    for (_, subJson) in errorsjson {
                        let code = subJson["code"].intValue
                        let text = subJson["text"].stringValue
                        println("erreur : \(code) = \(text)")
                        var nouvelleError = NSError(domain:"BetaSerieError", code:code, userInfo: ["text" : text])
                        handleError(nouvelleError)
                    }
                } else {
                    completionHandler(json)
                }
            }
        }
        task.resume()
    }
    
    func retrieveImage(completionHandler:(NSImage) -> ()) {
        let task = self.session.downloadTaskWithRequest(self.createRequest(), completionHandler: {url, response, error in
            completionHandler(NSImage(contentsOfURL:url)!)
        })
        
        task.resume()
    }
    
    private func createRequest() -> NSURLRequest {
        var request = NSMutableURLRequest()
        request.URL = self.urlForRequest()
        request.timeoutInterval = self.timeout
        request.HTTPMethod = self.httpMethod.rawValue
        
        return request
    }
    
    private func urlForRequest() -> NSURL {
        var url_final = "\(betaseries_api_url)\(self.category.rawValue)/\(self.method.rawValue)"
        
        if let objet = object {
            url_final += "/\(objet)"
        }
        
        if options.count > 0 {
            url_final += "?"
            
            for (cle, valeur) in options {
                url_final += "\(cle)=\(valeur)&"
            }
            
            url_final.removeAtIndex(url_final.endIndex.predecessor())            
        }
        url_final = url_final.stringByReplacingOccurrencesOfString(" ", withString: ".", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        return NSURL(string: url_final)!
    }
    
    func addOption(option: String, forName name: String) {
        self.options[name] = option
    }
}




protocol BSRequestDelegate {
    func request(request: BSRequest, didFailWithError error: NSError)
    
    func request(request: BSRequest, didReceivedDatas datas:NSDictionary)
}

