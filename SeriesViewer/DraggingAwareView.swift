//
//  DraggingAwareView.swift
//  SeriesViewer
//
//  Created by Clément NONN on 14/02/2015.
//  Copyright (c) 2015 Clément NONN. All rights reserved.
//

import Cocoa

class DraggingAwareView: NSView {
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        NSLog("dragging entered")
        let sourceDragMask = sender.draggingSourceOperationMask()
        let types = sender.draggingPasteboard().types as! [String]
        if contains(types, NSFilenamesPboardType) {
            if sourceDragMask.rawValue & NSDragOperation.Link.rawValue == NSDragOperation.Link.rawValue {
                NSLog("link accepted")
                return NSDragOperation.Link
            } else if sourceDragMask.rawValue & NSDragOperation.Copy.rawValue == NSDragOperation.Copy.rawValue /* && preference.accepteCopieFichier*/{
                NSLog("copy accepted")
                return NSDragOperation.Copy
            }
        }
        NSLog("nothing accepted")
        return NSDragOperation.None
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        NSLog("perform dragging")
        let sourceDragMask = sender.draggingSourceOperationMask()
        let pboard = sender.draggingPasteboard()
        // assuming we only have an NSFilenamesPBoardType possible
        
        if contains(pboard.types as! [String], NSFilenamesPboardType) {
            let urls = pboard.propertyListForType(NSFilenamesPboardType) as! [String]
            
            if sourceDragMask.rawValue & NSDragOperation.Link.rawValue == NSDragOperation.Link.rawValue {
                NSLog("linking")
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationsNames.fichierRecupere.rawValue, object: nil, userInfo: ["urls" : urls])
            } else {
                NSLog("moving")
            }
        }
        
        return true
        
    }
}