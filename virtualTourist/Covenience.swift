//
//  Covenience.swift
//  virtualTourist
//
//  Created by Andree Wijaya on 8/22/16.
//  Copyright © 2016 Andree Wijaya. All rights reserved.
//

import Foundation

struct Convenience {
    
    static func getImagesByLatLong(url: NSURL, pin: Pin,photos: [Photo], appDelegate: AppDelegate,completionHandlerForPhoto: (result: [Photo]?, error: NSError?)-> Void){
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: url )
        var photosTemp = photos
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            guard (error == nil) else{
                print("There is something wrong with the request \(error)")
                completionHandlerForPhoto(result: nil, error: error)
                return
            }
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                completionHandlerForPhoto(result: nil, error: NSError(domain: "getTask", code: 0, userInfo: nil))
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                
                completionHandlerForPhoto(result: nil, error: NSError(domain: "getTask", code: 3, userInfo: nil))
                return
            }
            
            let parsedResult: AnyObject!
            
            do{
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            }catch{
                print("Could not parse data")
                
                completionHandlerForPhoto(result: nil, error: NSError(domain: "getTask", code: 3, userInfo: nil))
                return
            }
            
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String where stat == Constants.FlickrResponseValues.OKStatus else {
                print("Flickr status was not OK!")
                
                completionHandlerForPhoto(result: nil, error: NSError(domain: "getTask", code: 1, userInfo: nil))
                return
            }
            
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else{
                print("Unable to get photos dictionary")
                
                completionHandlerForPhoto(result: nil, error: NSError(domain: "getTask", code: 1, userInfo: nil))
                return
            }
            
            guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                print("Unable to get photo array from dictionary")
                
                completionHandlerForPhoto(result: nil, error: NSError(domain: "getTask", code: 1, userInfo: nil))
                return
            }
            
            if photosArray.count == 0 {
                print("There are no photos in this area, search again")
            }else{
                for photoDictionary in photosArray{
                    guard let farmId = photoDictionary[Constants.FlickrPhotoParameterKeys.farm] as? NSNumber else{
                        print("Unabel to get Farm ID")
                        return
                    }
                    guard let serverId = photoDictionary[Constants.FlickrPhotoParameterKeys.server] as? String else {
                        print("Unable to get server ID")
                        return
                    }
                    guard let secret = photoDictionary[Constants.FlickrPhotoParameterKeys.secret] as? String else {
                        print("Unable go get secret")
                        return
                    }
                    
                    guard let photoID = photoDictionary[Constants.FlickrPhotoParameterKeys.photoId] as? String else {
                        print("Unable to get photo ID")
                        return
                    }
                    
                    let imageURL = "https://farm\(farmId).staticflickr.com/\(serverId)/\(photoID)_\(secret)_m.jpg"
                    let photo = Photo(pin: pin, imageUrl: imageURL, managedObjectContext: appDelegate.managedObjectContext)
                    
                    photosTemp.append(photo)
                    
                    appDelegate.saveContext()
                    
                }
                completionHandlerForPhoto(result: photosTemp, error: nil)
            }
            
            
        }
        
        task.resume()
        
    }

}
