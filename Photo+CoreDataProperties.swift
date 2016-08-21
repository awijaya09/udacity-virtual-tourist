//
//  Photo+CoreDataProperties.swift
//  virtualTourist
//
//  Created by Andree Wijaya on 8/21/16.
//  Copyright © 2016 Andree Wijaya. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var imageUrl: String?
    @NSManaged var pageNumber: NSNumber?
    @NSManaged var image: NSData?
    @NSManaged var pin: Pin?

}
