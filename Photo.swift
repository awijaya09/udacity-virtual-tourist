//
//  Photo.swift
//  virtualTourist
//
//  Created by Andree Wijaya on 8/21/16.
//  Copyright © 2016 Andree Wijaya. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(pin: Pin, imageUrl: String, managedObjectContext: NSManagedObjectContext){
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: managedObjectContext)
        super.init(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
        
        self.pin = pin
        self.imageUrl = imageUrl
    }
    
  }
