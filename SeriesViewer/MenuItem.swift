//
//  MenuItem.swift
//  SeriesViewer
//
//  Created by Clément NONN on 26/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Cocoa

class MenuItem: NSObject, Equatable {
    private(set) var nomItem: String
    internal(set) var items:[MenuItem]
    
    init(nom: String, items: [MenuItem]) {
        self.nomItem = nom
        self.items = items
    }
    
    func nombreEnfant() -> Int {
        return self.items.count
    }
    
    func nom() -> String {
        return self.nomItem
    }
}

func ==(item1:MenuItem, item2: MenuItem) -> Bool {
    return item1.nomItem == item2.nomItem
}

func !=(item1:MenuItem, item2: MenuItem) -> Bool {
    return !(item1 == item2)
}