//
//  HeaderItem.swift
//  SeriesViewer
//
//  Created by Clément NONN on 10/11/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Foundation

class HeaderItem : MenuItem {
    
    init(nom: String) {
        super.init(nom: nom, items: [Serie]())
    }
    
     func ajouterSeries(series:[Serie]) {
        for serie in series {
            self.items.append(serie)
        }
    }
    
     func ajouterSerie(serie:Serie) {
        self.items.append(serie)
    }
    
    func viderSeries() {
        self.items.removeAll()
    }
}