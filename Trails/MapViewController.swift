//
//  MapViewController.swift
//  Trails
//
//  Created by Rui Policarpo on 03/04/16.
//  Copyright © 2016 nExp. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase
import CoreData

class MapViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate{
    
    @IBOutlet weak var mvMap: MKMapView!
    
    @IBOutlet weak var sbSearch: UISearchBar!
    var coordinatesArray:[CLLocationCoordinate2D] = []
    var locationManager: CLLocationManager!
    var ref = FIRDatabaseReference.init()
    var trailsArray = [FIRDataSnapshot]()
    var trailIdSelected:String = ""
    var managedObjectContext: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let customTabBarController = self.tabBarController as? CustomUITabBarController {
            managedObjectContext = customTabBarController.managedObjectContext
        }
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        mvMap.showsUserLocation = true
        mvMap.delegate = self
        sbSearch.delegate = self
        
//        let location = CLLocationCoordinate2D(latitude: 38.754183, longitude: -9.189189)
//        
//        let annotation =  MKPointAnnotation()
//        
//        annotation.coordinate = location;
//        annotation.title = "Primeira Rota"
//        annotation.subtitle = "Caçar Lures"
//        
//        mvMap.addAnnotation(annotation)
        
        //        doubleToCoordinates([38.745872, -9.182045, 38.748226, -9.180504, 38.749448, -9.184356, 38.748891, -9.187589,38.748699, -9.188286, 38.747260, -9.188511, 38.746808, -9.184810])
        //       drawCoordinates()
        //
        
        ref = FIRDatabase.database().reference()
        ref.child("trails").child("pinInfo").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                self.trailsArray.append(rest)
                let trailInfoAnnotation = TrailInfo(title: (rest.value!["code"] as? String)!, subtitle: (rest.value!["name"] as? String)!, coordinate: CLLocationCoordinate2D(latitude: rest.value!["lat"] as! Double, longitude: rest.value!["long"] as! Double), id: rest.key)
                self.mvMap.addAnnotation(trailInfoAnnotation)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }
    
    
    
    // MARK: Core Location Delegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways {
            if CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    // do stuff
                }
            }
        }
    }
    
    // MARK: Buttons Actions
    
    @IBAction func showMyLocationPressed(sender: AnyObject) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake((locationManager.location?.coordinate)! , span)
        mvMap.setRegion(region , animated: true)
    }
    
    // MARK: Search Bar Delegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        searchBar.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
        
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.title = searchBar.text
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            let span = MKCoordinateSpanMake(0.3, 0.3)
            let region = MKCoordinateRegionMake(pointAnnotation.coordinate , span)
            self.mvMap.setRegion(region , animated: true)
            
        }
    }
    
    // MARK: Maps
    
    //    func doubleToCoordinates(coordinates:[Double]){
    //
    //        for (var i = 0 ; i < coordinates.count ; i = i+2)
    //        {
    //            coordinatesArray.append(CLLocationCoordinate2D(latitude: coordinates[i], longitude: coordinates[i+1]))
    //        }
    //    }
    //
    //    func drawCoordinates(){
    //
    //       let poly = MKPolygon(coordinates: &coordinatesArray, count: coordinatesArray.count)
    //        poly.title = "Segunda routa"
    //        poly.subtitle = "Sem lures 😢"
    //
    //        mvMap.addOverlay(poly);
    //       // MKPolygon(coordinates, coordinates.count)
    //    }
    //    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
    //        if overlay is MKPolygon {
    //            var polygonRenderer = MKPolygonRenderer(overlay: overlay)
    //            polygonRenderer.fillColor = UIColor.cyanColor().colorWithAlphaComponent(0.2)
    //            polygonRenderer.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.7)
    //            polygonRenderer.lineWidth = 3
    //            return polygonRenderer
    //        }
    //
    //        return nil
    //    }
    
    
    // MARK: - Map view delegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Capital"
        
        if annotation.isKindOfClass(TrailInfo.self) {
            if let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) {
                annotationView.annotation = annotation
                return annotationView
            } else {
                let annotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier:identifier)
                annotationView.enabled = true
                annotationView.canShowCallout = true
                
                let image = UIImage(named: "moreInfo") as UIImage?
                let buttonMore   = UIButton(type: UIButtonType.Custom) as UIButton
                buttonMore.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                buttonMore.setImage(image, forState: .Normal)
                buttonMore.tag = 100
                annotationView.leftCalloutAccessoryView = buttonMore
                return annotationView
            }
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //I don't know how to convert this if condition to swift 1.2 but you can remove it since you don't have any other button in the annotation view
        if (control as? UIButton)?.tag == 100 {
            mapView.deselectAnnotation(view.annotation, animated: false)
            performSegueWithIdentifier("trailDetail", sender: view.annotation)
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "trailDetail"{
            let newVC:SingleTrailDetail = segue.destinationViewController as! SingleTrailDetail
            newVC.managedObjectContext = self.managedObjectContext
            sender as! TrailInfo
            newVC.trailId = (sender?.id)!
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


class TrailInfo: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var id: String
    
    init(title: String,subtitle: String, coordinate: CLLocationCoordinate2D, id: String) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.id = id
    }
}