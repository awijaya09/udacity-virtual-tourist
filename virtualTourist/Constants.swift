//
//  Constants.swift
//  virtualTourist
//
//  Created by Andree Wijaya on 8/9/16.
//  Copyright © 2016 Andree Wijaya. All rights reserved.
//

import Foundation


struct Constants {
    
    struct Flickr {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
    }
    
    struct FlickrParameterKeys{
        static let Method = "method"
        static let APIKey = "api_key"
        static let latitude = "lat"
        static let longitude = "lon"
        static let perPage = "per_page"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let page = "page"
        static let perpage = "perpage"
        
    
    }
    
    struct FlickrParameterValues {
        static let searchMethod = "flickr.photos.search"
        static let apiKey = "0ddd786802fff7a4a80c78a57bf01de4"
        static let perPage = "21"
        static let format = "json"
        static let noJsonCallback = "1"
        static let safeSearch = "1"
        
    }
    
    struct FlickrPhotoParameterKeys {
        static let farm = "farm"
        static let server = "server"
        static let secret = "secret"
        static let photoId = "id"
    }
    
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
    }
    
    struct  FlickrResponseValues {
        static let OKStatus = "ok"
    }
}