//
//  DefaultContentViewController.swift
//  SeriesViewer
//
//  Created by Clément NONN on 06/12/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Cocoa

class DefaultContentViewController: NSViewController {
    
    convenience init?(nibName:String = "DefaultContentView") {
        self.init(nibName: nibName, bundle: nil)
    }
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
