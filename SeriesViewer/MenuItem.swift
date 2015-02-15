//
//  MenuItem.swift
//  SeriesViewer
//
//  Created by Clément NONN on 26/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Cocoa


protocol MenuItem: NSCoding, NSCopying {
    var nomItem: String { get }
    var items:[AnyObject] { get }
    var cellIdentifier: String { get }
}

func ==(item1:MenuItem, item2: MenuItem) -> Bool {
    return item1.nomItem == item2.nomItem
}

func !=(item1:MenuItem, item2: MenuItem) -> Bool {
    return !(item1 == item2)
}