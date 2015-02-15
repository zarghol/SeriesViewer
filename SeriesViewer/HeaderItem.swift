//
//  HeaderItem.swift
//  SeriesViewer
//
//  Created by Clément NONN on 10/11/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Foundation

class HeaderItem : NSObject, NSCopying, NSCoding, MenuItem {
    var nomItem: String
    private(set)var series: [Serie]
    
    
    var items: [AnyObject] {
        return self.series
    }
    
    var cellIdentifier: String {
        return "HeaderCell"
    }
    
    init(nom: String) {
        self.nomItem = nom
        self.series = [Serie]()
    }
    
    init(headerItem: HeaderItem) {
        self.nomItem = headerItem.nomItem
        self.series = headerItem.series
    }

    required init(coder aDecoder: NSCoder) {
        self.nomItem = aDecoder.decodeObjectForKey("nomHeader") as! String
        self.series = aDecoder.decodeObjectForKey("itemsSeries") as! [Serie]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.nomItem, forKey: "nomHeader")
        aCoder.encodeObject(self.series, forKey: "itemsSeries")
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return HeaderItem(headerItem: self)
    }
    
     func ajouterSeries(series:[Serie]) {
        self.series.extend(series)
    }
    
     func ajouterSerie(serie:Serie) {
        self.series.append(serie)
    }
    
    func viderSeries() {
        self.series.removeAll()
    }
}