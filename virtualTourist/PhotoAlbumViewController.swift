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
    var itemCount = 21
    var pin: Pin!
    var appDelegate: AppDelegate!
    var sharedContext: NSManagedObjectContext!
    var photos: [Photo]!
    var page = 1
    var isDownloading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var initialLocation = CLLocation()
        if let pin = pin {
             initialLocation = CLLocation(latitude: pin.latitude as! Double, longitude: pin.longitude as! Double)
        }
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        sharedContext = appDelegate.managedObjectContext
        mapView.delegate = self
            
            self.photos = self.getAllPhotos()
            self.centerLocation(initialLocation)
            
            
            self.mapView.addAnnotation(self.pin)
            
            self.page = Int((arc4random_uniform(UInt32(190)))) + 1
            print("downloading page number : \(self.page)")
            
            let parameters: [String: String!] = [Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.searchMethod,
                Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.apiKey,
                Constants.FlickrParameterKeys.latitude: "\(self.pin.latitude!)",
                Constants.FlickrParameterKeys.longitude: "\(self.pin.longitude!)",
                Constants.FlickrParameterKeys.perPage: "21",
                Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.format,
                Constants.FlickrParameterKeys.NoJSONCallback: "1",
                Constants.FlickrParameterKeys.page:"\(self.page)"
                
            ]
            if (!self.photos.isEmpty){
                print("No download")
            }else{
                Convenience.getImagesByLatLong(self.flickrURLFromParameter(parameters),pin: self.pin,photos: self.photos, appDelegate: self.appDelegate, completionHandlerForPhoto: { (result, error) in
                    guard (error == nil) else{
                        print("Some error in the networking code: \(error)")
                        return
                    }
                    
                    self.photos = result
                    performUIUpdatesOnMain({
                        self.collectionView.reloadData()
                        self.isDownloading = false
                    })
                })
                
            }
            
        
    }
    
    @IBAction func getNewSetOfImages(sender: AnyObject) {
        
        isDownloading = true
        for photo in photos {
            sharedContext.deleteObject(photo)
        }
        appDelegate.saveContext()
        photos.removeAll()
        itemCount = 21
        collectionView.reloadData()
        
        page = Int((arc4random_uniform(UInt32(30)))) + 1
        print("downloading page number : \(page)")

        let parameters: [String: String!] = [Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.searchMethod,
                                             Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.apiKey,
                                             Constants.FlickrParameterKeys.latitude: "\(pin.latitude!)",
                                             Constants.FlickrParameterKeys.longitude: "\(pin.longitude!)",
                                             Constants.FlickrParameterKeys.perPage: "21",
                                             Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.format,
                                             Constants.FlickrParameterKeys.NoJSONCallback: "1",
                                             Constants.FlickrParameterKeys.page:"\(page)"
            
        ]
        
        Convenience.getImagesByLatLong(flickrURLFromParameter(parameters),pin: self.pin,photos: self.photos, appDelegate: self.appDelegate, completionHandlerForPhoto: { (result, error) in
            print("downloading in progress")
            guard (error == nil) else{
                print("Some error in the networking code: \(error)")
                return
            }
            
            self.photos = result
            performUIUpdatesOnMain({
                self.collectionView.reloadData()
                self.isDownloading = false
            })
            
        })
        
        
    }
    func getAllPhotos()-> [Photo]{
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format:"pin == %@", pin)
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
        if (photos.isEmpty){
            print("no item")
            return itemCount
        }else{
            
            return photos.count
        }
    }
    func updateImageData(data: NSData, imageUrl: String){
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "imageUrl == %@", imageUrl)
        do{
            if let fetchedResult = try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
                if (fetchedResult.count != 0){
                    let managedObject = fetchedResult[0]
                    managedObject.setValue(data, forKey: "image")
                    
                    try sharedContext.save()
                }
            }
        } catch{
            print("update failed")
            return
        }
       
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photo", forIndexPath: indexPath) as! FlickrCell
       
        
        if (!photos.isEmpty){
            
            let pht = photos[indexPath.row]
            if (pht.image == nil){
                print("Downloading image")
                if let urlPht = pht.imageUrl {
                    performImageDownload(urlPht, updates: {
                        if let url = NSURL.init(string: urlPht) {
                            let data = NSData.init(contentsOfURL: url)
                            pht.image = data
                        
                            performUIUpdatesOnMain({
                                self.updateImageData(data!, imageUrl: pht.imageUrl!)
                                cell.imageView.image = UIImage(data: pht.image!)
                                cell.activityIndicator.stopAnimating()
                                self.isDownloading = false
                            })
                        }
                    })
                }
            }else{
                print("using images from coredata")
                performUIUpdatesOnMain({ 
                    cell.imageView.image = UIImage(data: pht.image!)
                    cell.activityIndicator.stopAnimating()
                    self.isDownloading = false
                })
            }
            
            
           

        }else{
            performUIUpdatesOnMain({ 
                
                cell.imageView.image = nil
                cell.activityIndicator.startAnimating()
            })
        }
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
            let photo = photos[indexPath.row]
        
            let index = NSIndexPath(forRow: indexPath.row, inSection: 0)
            let indexPaths = [index]
            sharedContext.deleteObject(photo)
            collectionView.deleteItemsAtIndexPaths(indexPaths)
            photos.removeAtIndex(indexPath.row)
        
            appDelegate.saveContext()
        
        
    }
    
    
    
}
