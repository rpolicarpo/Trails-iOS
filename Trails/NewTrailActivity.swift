//
//  NewTrailActivity.swift
//  Trails
//
//  Created by Rui Policarpo on 07/08/16.
//  Copyright © 2016 nExp. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation
import HealthKit
import MapKit
import FirebaseDatabase


class NewTrailActivity: UIViewController{

    @IBOutlet weak var mapView: MKMapView!
    var seconds = 0.0
    var distance = 0.0
    let userDefauls = NSUserDefaults.standardUserDefaults()
    var ref = FIRDatabaseReference.init()
    var trailRef:NSString = NSString()
    var trailName:NSString = NSString()
    var trailCode:NSString = NSString()
    var annotations:NSArray = NSArray()
    var overlays:NSArray = NSArray()
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = .Fitness
        // Movement threshold for new events
        _locationManager.distanceFilter = 0.5
        return _locationManager
    }()
    
    lazy var locations = [CLLocation]()
    lazy var timer = NSTimer()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.addOverlays(overlays as! [MKOverlay])
        self.mapView.addAnnotations(annotations as! [MKAnnotation])
        
        var flyTo: MKMapRect = MKMapRectNull
        for overlay in overlays {
            let overlayMKOverlay = overlay as! MKOverlay
            if MKMapRectIsNull(flyTo) {
                flyTo = overlayMKOverlay.boundingMapRect
            }
            else {
                flyTo = MKMapRectUnion(flyTo, overlayMKOverlay.boundingMapRect)
            }
        }
        
        for annotation in annotations {
            let annotationMKAnnotation = annotation as! MKAnnotation
            let annotationPoint: MKMapPoint = MKMapPointForCoordinate(annotationMKAnnotation.coordinate)
            let pointRect: MKMapRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0)
            if MKMapRectIsNull(flyTo) {
                flyTo = pointRect
            }
            else {
                flyTo = MKMapRectUnion(flyTo, pointRect)
            }
        }
        
        // Position the map so that all overlays and annotations are visible on screen.
        self.mapView.visibleMapRect = mapView.mapRectThatFits(flyTo, edgePadding: UIEdgeInsetsMake(10, 10, 10, 10))
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
//        mapView.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func backAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    var managedObjectContext: NSManagedObjectContext?
    
    var run: Run!
    
    @IBOutlet weak var trailCodeLabel: UILabel!
    @IBOutlet weak var trailNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var cancelButton: Button02!
    @IBOutlet weak var rulerImage: UIImageView!
    @IBOutlet weak var clockImage: UIImageView!
    @IBOutlet weak var emergencyButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.requestAlwaysAuthorization()
        emergencyButton.layer.cornerRadius = 5
        emergencyButton.hidden = true
        rulerImage.hidden = true
        clockImage.hidden = true
        startButton.hidden = false
        cancelButton.hidden = false
        timeLabel.hidden = true
        distanceLabel.hidden = true
//        paceLabel.hidden = true
        stopButton.hidden = true
        self.mapView.layer.cornerRadius = 10
        
        trailCodeLabel.text = trailCode as String
        trailCodeLabel.backgroundColor = kGR1
        trailCodeLabel.layer.cornerRadius = 10
        trailCodeLabel.layer.masksToBounds = true
        trailNameLabel.text = trailName as String
    }
    
    @IBAction func startPressed(sender: AnyObject) {
        emergencyButton.hidden = false
        startButton.hidden = true
        rulerImage.hidden = false
        clockImage.hidden = false
        timeLabel.hidden = false
        distanceLabel.hidden = false
//        paceLabel.hidden = false
        stopButton.hidden = false
        mapView.hidden = false
        
        seconds = 0.0
        distance = 0.0
        locations.removeAll(keepCapacity: false)
        timer = NSTimer.scheduledTimerWithTimeInterval(1,
                                                       target: self,
                                                       selector: #selector(NewTrailActivity.eachSecond(_:)),
                                                       userInfo: nil,
                                                       repeats: true)
        startLocationUpdates()
        
    }
    
    @IBAction func stopPressed(sender: AnyObject) {
        let alertController = UIAlertController(title: "Acabou a caminhada?", message: nil, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let SaveAction = UIAlertAction(title: "Guardar", style: .Default) { (action) in
            self.saveRun()
            self.performSegueWithIdentifier("DetailTrailActivity", sender: nil)
        }
        
        let DiscardAction = UIAlertAction(title: "Descartar", style: .Destructive) { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(SaveAction)
        alertController.addAction(DiscardAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailViewController = segue.destinationViewController as? PastTrailActivity {
            detailViewController.run = run
        }
    }
    
    func eachSecond(timer: NSTimer) {
        seconds += 1
        let secondsQuantity = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: seconds)
        timeLabel.text = "Duração: " + secondsQuantity.description
        let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: distance)
        distanceLabel.text = "Distância: " + distanceQuantity.description
        
        
        
//        let paceUnit = HKUnit.secondUnit().unitDividedByUnit(HKUnit.meterUnit())
//        let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: seconds / distance)
//        paceLabel.text = "Pace: " + paceQuantity.description
    }
    
    func startLocationUpdates() {
        // Here, the location manager will be lazily instantiated
        locationManager.startUpdatingLocation()
    }
    
    
    func saveRun(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let savedRun = NSEntityDescription.insertNewObjectForEntityForName("Run",inManagedObjectContext: managedContext!) as! Run
        savedRun.distance = distance
        savedRun.duration = seconds
        savedRun.timestamp = NSDate()
        savedRun.trailRef = self.trailRef
        savedRun.trailName = self.trailName
        savedRun.trailCode = self.trailCode
        savedRun.points = Double(String(format:"%.2f", (Double(savedRun.distance)/1000)))!
        
        var savedLocations = [Location]()
        for location in locations {
            let savedLocation = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: managedContext!) as! Location
            savedLocation.timestamp = location.timestamp
            savedLocation.latitude = location.coordinate.latitude
            savedLocation.longitude = location.coordinate.longitude
            savedLocations.append(savedLocation)
        }
        
        savedRun.locations = NSMutableOrderedSet(array: savedLocations)
        run = savedRun
        
        do {
            try managedContext!.save()
        } catch let error as NSError? {
            print("Could not save the run! \(error)")
        }
        
        var distanceSaved = Double(userDefauls.stringForKey("distance")!)
        distanceSaved = distanceSaved! + Double(String(format:"%.2f", (Double(savedRun.distance)/1000)))!
        let ref = FIRDatabase.database().reference().child("users").child((userDefauls.objectForKey("userUid") as? String)!)
        ref.updateChildValues(["distance":distanceSaved! as Double, "points":Int(distanceSaved!*10)])
        ref.observeSingleEventOfType(FIRDataEventType.ChildChanged, withBlock: { (snapshot) in
        })
        self.userDefauls.setObject(distanceSaved! as Double, forKey: "distance")
        self.userDefauls.setObject(Int(distanceSaved!*10), forKey: "points")

    }
    @IBAction func callEmergencyButton(sender: AnyObject) {
        let alertController = UIAlertController(title: "Ligar 112", message: nil, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let callAction = UIAlertAction(title: "SIM", style: .Default) { (action) in
            let url:NSURL = NSURL(string: "tel://112")!
            UIApplication.sharedApplication().openURL(url)
        }
        
        alertController.addAction(callAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }

    }
}

// MARK: - CLLocationManagerDelegate
extension NewTrailActivity: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        for location in locations {
            let howRecent = location.timestamp.timeIntervalSinceNow
            
            if abs(howRecent) < 10 && location.horizontalAccuracy < 20 {
                //update distance
                if self.locations.count > 0 {
                    distance += location.distanceFromLocation(self.locations.last!)
                    
                    var coords = [CLLocationCoordinate2D]()
                    coords.append(self.locations.last!.coordinate)
                    coords.append(location.coordinate)
                    
                    let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
//                    mapView.setRegion(region, animated: true)
                    
                    mapView.addOverlay(MKPolyline(coordinates: &coords, count: coords.count))
                }
                
                //save location
                self.locations.append(location)
            }
        }    }
}

// MARK: - MKMapViewDelegate
extension NewTrailActivity: MKMapViewDelegate {
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if !overlay.isKindOfClass(MKPolyline) {
            return nil
        }
        
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 3
        return renderer
    }
}
 