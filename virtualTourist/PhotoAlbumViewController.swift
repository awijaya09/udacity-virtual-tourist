//
//  PhotoAlbumViewController.swift
//  virtualTourist
//
//  Created by Andree Wijaya on 8/9/16.
//  Copyright © 2016 Andree Wijaya. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var collectionView: UICollectionView!
    var pin: Pin!
    var appDelegate: AppDelegate!
    var sharedContext: NSManagedObjectContext!
    var photos: [Photo]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var initialLocation = CLLocation()
        if let pin = pin {
             initialLocation = CLLocation(latitude: pin.latitude as! Double, longitude: pin.longitude as! Double)
        }
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        sharedContext = appDelegate.managedObjectContext
        photos = getAllPhotos()
        print(pin)
        centerLocation(initialLocation)
        
        mapView.delegate = self
        mapView.addAnnotation(pin)
        
        
        let parameters: [String: String!] = [Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.searchMethod,
                                            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.apiKey,
                                            Constants.FlickrParameterKeys.latitude: "\(pin.latitude!)",
                                            Constants.FlickrParameterKeys.longitude: "\(pin.longitude!)",
                                            Constants.FlickrParameterKeys.perPage: "21",
                                            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.format,
                                            Constants.FlickrParameterKeys.NoJSONCallback: "1"
                                            ]
        
        getImageFromFlickrByLatLong(parameters) { (error) in
            guard (error == nil) else{
                print("Something wrong with getting the image \(error)")
                return
            }
        }
    }
    
    func getAllPhotos()-> [Photo]{
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        var results = [AnyObject]()
        do{
            results = try sharedContext.executeFetchRequest(fetchRequest)
        }catch {
            print("Error in fetching data")
        }
        
        return results as! [Photo]
    }

    
    func centerLocation (location: CLLocation){
        let radius: CLLocationDistance = 1000
        let coordinate = MKCoordinateRegionMakeWithDistance(location.coordinate, radius*2, radius*2)
        mapView.setRegion(coordinate, animated: true)
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var view: MKPinAnnotationView
        let identifier = "pin"
        
        if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView{
            dequeuedView.annotation = annotation
            view = dequeuedView
        }else{
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        
        return view
    }
    
    //Getting the links for Flickr
    func flickrURLFromParameter (parameters: [String:AnyObject]) -> NSURL{
        let components = NSURLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems?.append(queryItem)
        }
        
        return components.URL!
        
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 21
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photo", forIndexPath: indexPath) as! FlickrCell
        
        let pht = photos[indexPath.row]
        cell.activityIndicator.stopAnimating()
        cell.imageView.image = pht.image
        
        return cell
    }
    
    func getImageFromFlickrByLatLong (methodParameters:[String:AnyObject], completionHandler:(error: NSError?)-> Void){
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: flickrURLFromParameter(methodParameters))
        print(flickrURLFromParameter(methodParameters))
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            guard (error == nil) else{
                print("There is something wrong with the request \(error)")
                completionHandler(error: error)
                return
            }
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                completionHandler(error: NSError(domain: "getTask", code: 0, userInfo: nil))
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                
                completionHandler(error: NSError(domain: "getTask", code: 3, userInfo: nil))
                return
            }
            
            let parsedResult: AnyObject!
            
            do{
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            }catch{
                print("Could not parse data")
                
                completionHandler(error: NSError(domain: "getTask", code: 3, userInfo: nil))
                return
            }
            
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String where stat == Constants.FlickrResponseValues.OKStatus else {
                print("Flickr status was not OK!")
                
                completionHandler(error: NSError(domain: "getTask", code: 1, userInfo: nil))
                return
            }
            
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else{
                print("Unable to get photos dictionary")
                
                completionHandler(error: NSError(domain: "getTask", code: 1, userInfo: nil))
                return
            }
            
            guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                print("Unable to get photo array from dictionary")
                
                completionHandler(error: NSError(domain: "getTask", code: 1, userInfo: nil))
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
                    
                    let imageURL = "https://farm\(farmId)/\(serverId)/\(photoID)_\(secret)_m.jpg"
                    
                    let photo = Photo(imageUrl: imageURL, pin: self.pin, managedObjectContext: self.appDelegate!.managedObjectContext)
                    
                    self.photos.append(photo)
                    self.appDelegate!.saveContext()
                    
//                    performUIUpdatesOnMain({ 
//                        self.collectionView.reloadData()
//                    })
                    completionHandler(error: nil)
                }
            }
            
            
        }
        
        task.resume()
    }
}
