//
//  SerieContentViewController.swift
//  SeriesViewer
//
//  Created by Clément NONN on 06/12/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Cocoa

class SerieContentViewController: NSViewController {
    
    var serie: Serie!
    
    @IBOutlet weak var visualEffectView: NSVisualEffectView!
    @IBOutlet weak var banniereImageView: NSImageView!
    @IBOutlet weak var titreTextView: NSTextField!
    @IBOutlet weak var dureeEpisodeTextView: NSTextField!
    @IBOutlet weak var genresTextView: NSTextField!
    @IBOutlet weak var statutTextView: NSTextField!
    @IBOutlet var descriptionTextView: NSTextView!
    // TODO archive/active segment control
    
    convenience init?(nibName:String = "SerieContentView") {
        self.init(nibName: nibName, bundle: nil)
    }
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.recupBanniere()
        //self.visualEffectView
        self.titreTextView.stringValue = self.serie.nomItem
        self.visualEffectView.invalidateIntrinsicContentSize()
        self.dureeEpisodeTextView.integerValue = self.serie.dureeEpisode
        self.genresTextView.stringValue = self.serie.genres.reduce("", combine: {$0 + $1 + "\n"})
        self.statutTextView.stringValue = self.serie.status.rawValue
        self.descriptionTextView.string = self.serie.descriptionSerie
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "recupBanniere", name: "banniereRecupere", object: nil)
    }
    
    func recupBanniere() {
        if let urlImage = self.serie.banner {
            if let nsUrlImage = NSURL(string: urlImage) {
                self.banniereImageView.image = NSImage(byReferencingURL: nsUrlImage)
            }
        }
    }
    
}
