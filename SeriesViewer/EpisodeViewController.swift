//
//  EpisodeViewController.swift
//  SeriesViewer
//
//  Created by Clément NONN on 23/12/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Cocoa
import AVKit
import AVFoundation

class EpisodeViewController: NSViewController {
    
    @IBOutlet weak var titreTextField: NSTextField!
    @IBOutlet weak var playerView: AVPlayerView!
    @IBOutlet weak var chercherFichierButton: NSButton!
    @IBOutlet weak var vueSegmentedControl: NSSegmentedControl!
    @IBOutlet var descriptionView: NSTextView!
    
    
    var episode: Episode!
    
    convenience init?(nibName:String = "EpisodeView") {
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
        // Do view setup here.
        
        self.titreTextField.stringValue = self.episode.nomItem
        self.descriptionView.string = self.episode.descriptionEpisode
        self.vueSegmentedControl.selectedSegment = self.episode.vue ? 0 : 1
        
        self.essayeDeLanceVideo()
    }
    
    @IBAction func chercheFichier(sender: NSButton) {
        var panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["mp4"]
        panel.beginSheetModalForWindow(self.view.window!, completionHandler: { result in
            if result == NSFileHandlingPanelOKButton {
                self.episode.lien = panel.URLs[0] as? NSURL
                self.essayeDeLanceVideo()
            }
        })
    }
    
    func essayeDeLanceVideo() {
        self.chercherFichierButton.hidden = self.episode.lien != nil
        self.playerView.hidden = !self.chercherFichierButton.hidden
        
        if let lien = self.episode.lien {
            self.playerView.player = AVPlayer(URL: lien)
            self.playerView.player.play()
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoFinie", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        }
    }
    
    @IBAction func changeVue(sender: NSSegmentedControl) {
        self.episode.vue = sender.selectedSegment == 0
    }
    
    func videoFinie() {
        self.episode.vue = true
    }
}
