//
//  GCDBlackBox.swift
//  virtualTourist
//
//  Created by Andree Wijaya on 8/9/16.
//  Copyright © 2016 Andree Wijaya. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}

func performImageDownload(url: String, updates: () -> Void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
        updates()
    })
}