//
//  ViewController.swift
//  virtualTourist
//
//  Created by Andree Wijaya on 8/9/16.
//  Copyright © 2016 Andree Wijaya. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MainMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toolbar: UIToolbar!
    var appDelegate: AppDelegate!
    var sharedContext: NSManagedObjectContext!
    
    var inEditMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toolbar.hidden = true
        //initializing app delegate and context
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        sharedContext = appDelegate.managedObjectContext
        
        //setting the initial location to Surabaya
        let initialLocation = CLLocation(latitude: -7.250435, longitude: 112.751849)
        centerLocation(initialLocation)
        
        //adding gesture recognizer for adding pin during tapping
        setGestureRecognizer()
        mapView.delegate = self
        
        mapView.addAnnotations(getAllPins())
        
    }
    
    @IBAction func editMode(sender: AnyObject) {
        inEditMode = !inEditMode
        
        if (inEditMode){
            editButton.title = "Done"
            toolbar.hidden = false
            for recognizer in mapView.gestureRecognizers! {
                mapView.removeGestureRecognizer(recognizer)
            }
        }else{
            editButton.title = "Edit"
            toolbar.hidden = true
            setGestureRecognizer()
        }
    }
    
    func setGestureRecognizer(){
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(MainMapViewController.dropPin(_:)))
        longPress.minimumPressDuration = 0.5
        
        mapView.addGestureRecognizer(longPress)

    }
    func centerLocation (location: CLLocation){
        let radius: CLLocationDistance = 10000
        let coordinate = MKCoordinateRegionMakeWithDistance(location.coordinate, radius*2, radius*2)
        mapView.setRegion(coordinate, animated: true)
    }

    //dropping pin and adding them to coredata
    func dropPin(gestureRecognizer: UIGestureRecognizer){
        let point: CGPoint = gestureRecognizer.locationInView(mapView)
        
        let pointCoordinate: CLLocationCoordinate2D = mapView.convertPoint(point, toCoordinateFromView: mapView)
        
        if UIGestureRecognizerState.Began == gestureRecognizer.state {
            let pin = Pin(annotationLatitude: pointCoordinate.latitude, annotationLongitude: pointCoordinate.longitude, context: appDelegate!.managedObjectContext)
            performUIUpdatesOnMain({
                self.mapView.addAnnotation(pin)
                self.appDelegate!.saveContext()
            })
        }
    }
    
    //getting all pins from coredata
    func getAllPins()-> [Pin]{
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        var results = [AnyObject]()
        do{
            results = try sharedContext.executeFetchRequest(fetchRequest)
        }catch {
            print("Error in fetching data")
        }
        
        return results as! [Pin]
    }
    
    //functions to display the annotation pin
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

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let pin = view.annotation as! Pin
        
        if (inEditMode){
            sharedContext.deleteObject(pin)
            mapView.removeAnnotation(pin)
            appDelegate.saveContext()
        }else{
            mapView.deselectAnnotation(pin, animated: true)
            performSegueWithIdentifier("getPhotoAlbum", sender: pin)
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "getPhotoAlbum" {
            let destination = segue.destinationViewController as! PhotoAlbumViewController
            destination.pin = sender as! Pin
            
            //setting the back button item
            let backButton = UIBarButtonItem()
            backButton.title = "Back"
            navigationItem.backBarButtonItem = backButton
        }
    }

}

