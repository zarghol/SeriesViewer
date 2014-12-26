//
//  MenuItem.swift
//  SeriesViewer
//
//  Created by Clément NONN on 26/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Cocoa

class MenuItem: NSObject, Equatable, NSCoding, NSCopying {
    private(set) var nomItem: String
    internal(set) var items:[MenuItem]
    
    init(nom: String, items: [MenuItem]) {
        self.nomItem = nom
        self.items = items
    }
    
    required init(coder aDecoder: NSCoder) {
        self.nomItem = aDecoder.decodeObjectForKey("nomItem") as String
        self.items = aDecoder.decodeObjectForKey("items") as [MenuItem]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.nomItem, forKey: "nomItem")
        aCoder.encodeObject(self.items, forKey: "items")
    }
    
    func nombreEnfant() -> Int {
        return self.items.count
    }
    
    func nom() -> String {
        return self.nomItem
    }
    
    func trie() {
        for item in self.items {
            item.trie()
        }
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return MenuItem(nom: self.nomItem, items:items)
    }
}

func ==(item1:MenuItem, item2: MenuItem) -> Bool {
    return item1.nomItem == item2.nomItem
}

func !=(item1:MenuItem, item2: MenuItem) -> Bool {
    return !(item1 == item2)
}