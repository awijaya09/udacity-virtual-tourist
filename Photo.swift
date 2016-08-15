//
//  Photo.swift
//  virtualTourist
//
//  Created by Andree Wijaya on 8/9/16.
//  Copyright © 2016 Andree Wijaya. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class Photo: NSManagedObject {


    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(imageUrl: String, pin: Pin, managedObjectContext: NSManagedObjectContext){
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: managedObjectContext)
        super.init(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
        
        self.imageUrl = imageUrl
        self.pin = pin
        
    }
    
    func getFilePath()-> NSURL{
        let fileName = (imagePath! as NSString).lastPathComponent
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let pathArray:[String] = [dirPath, fileName]
        let fileURL = NSURL.fileURLWithPathComponents(pathArray)
        return fileURL!
    }
    
    var image: UIImage? {
        if imagePath != nil {
            let fileURL = getFilePath()
            return UIImage(contentsOfFile: fileURL.path!)
        }
        return nil
    }
}
