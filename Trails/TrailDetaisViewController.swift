//
//  TrailDetaisViewController.swift
//  Trails
//
//  Created by Rui Policarpo on 23/07/16.
//  Copyright © 2016 nExp. All rights reserved.
//

import Foundation
import UIKit
import iCarousel
import FirebaseDatabase
import FirebaseStorage
import Firebase
import MapKit

//funções que precisam de ser implementadas nas views que usarem este componente
protocol TrailDetailsDelegate: class {
    func getTrailsArray () -> NSArray
    func getUpdateData ()
}

class TrailDetaisViewController:UIImageView,iCarouselDataSource, iCarouselDelegate, MKMapViewDelegate, CLLocationManagerDelegate{
    // Our custom view from the XIB file
    var view: UIView!
    weak var delegate:TrailDetailsDelegate?
    var refreshControl: UIRefreshControl!
    var items: [FIRDataSnapshot] = []
    var ref = FIRDatabaseReference.init()
    var comeFrom:NSString = ""
    var kmlParser:KMLParser = KMLParser()
    let locationManager = CLLocationManager()
    var userCurrentLocation = CLLocation()
    var trailRef:NSString = NSString()
    var trailName:NSString = NSString()
    var trailCode:NSString = NSString()
    var annotations:NSArray = NSArray()
    var overlays:NSArray = NSArray()
    
    @IBOutlet weak var TextViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var carousel: iCarousel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var animalsLabel: UILabel!
    @IBOutlet weak var plantsLabel: UILabel!
    @IBOutlet weak var poiLabel: UILabel!
    @IBOutlet weak var dificultyLabel: UILabel!
    @IBOutlet weak var dificultyLevelImage: UIImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    
    let storage = FIRStorage.storage()

    
    func xibSetup() {
        
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        refreshControl = UIRefreshControl()
        addSubview(view)
        
        scrollView.addSubview(refreshControl)
        refreshControl.bounds = CGRectMake(refreshControl.bounds.origin.x, refreshControl.bounds.origin.y-20, refreshControl.bounds.size.width, refreshControl.bounds.size.height)
        refreshControl.addTarget(self, action: #selector(onRefresh), forControlEvents: .ValueChanged)
        
        let shadowColor:CGColor =  UIColor.blackColor().CGColor
        let shadowOffset:CGSize = CGSizeMake(0.0, 0.0)
        let shadowRadius:CGFloat = 6.0
        let shadowOpacity:Float = 0.7
        
        
        self.distanceLabel.layer.shadowColor = shadowColor
        self.distanceLabel.layer.shadowOffset = shadowOffset
        self.distanceLabel.layer.shadowRadius = shadowRadius
        self.distanceLabel.layer.shadowOpacity = shadowOpacity
        
        self.durationLabel.layer.shadowColor = shadowColor
        self.durationLabel.layer.shadowOffset = shadowOffset
        self.durationLabel.layer.shadowRadius = shadowRadius
        self.durationLabel.layer.shadowOpacity = shadowOpacity

        self.descriptionTextView.layer.shadowColor = shadowColor
        self.descriptionTextView.layer.shadowOffset = shadowOffset
        self.descriptionTextView.layer.shadowRadius = shadowRadius
        self.descriptionTextView.layer.shadowOpacity = shadowOpacity

        self.animalsLabel.layer.shadowColor = shadowColor
        self.animalsLabel.layer.shadowOffset = shadowOffset
        self.animalsLabel.layer.shadowRadius = shadowRadius
        self.animalsLabel.layer.shadowOpacity = shadowOpacity
        
        self.plantsLabel.layer.shadowColor = shadowColor
        self.plantsLabel.layer.shadowOffset = shadowOffset
        self.plantsLabel.layer.shadowRadius = shadowRadius
        self.plantsLabel.layer.shadowOpacity = shadowOpacity
        
        self.poiLabel.layer.shadowColor = shadowColor
        self.poiLabel.layer.shadowOffset = shadowOffset
        self.poiLabel.layer.shadowRadius = shadowRadius
        self.poiLabel.layer.shadowOpacity = shadowOpacity
        
        self.dificultyLabel.layer.shadowColor = shadowColor
        self.dificultyLabel.layer.shadowOffset = shadowOffset
        self.dificultyLabel.layer.shadowRadius = shadowRadius
        self.dificultyLabel.layer.shadowOpacity = shadowOpacity
        
        self.cityNameLabel.layer.shadowColor = shadowColor
        self.cityNameLabel.layer.shadowOffset = shadowOffset
        self.cityNameLabel.layer.shadowRadius = shadowRadius
        self.cityNameLabel.layer.shadowOpacity = shadowOpacity
        
        self.mapView.delegate = self
        self.mapView.layer.cornerRadius = 10
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

    }
    
    func parseKMLandCreateMap (path: NSString){
        let overlaysToDelete = self.mapView.overlays
        self.mapView.removeOverlays(overlaysToDelete)
        
        let annotationsToDelete = self.mapView.annotations
        self.mapView.removeAnnotations(annotationsToDelete)
        
        // Locate the path to the route.kml file in the application's bundle
        // and parse it with the KMLParser.
        let url:NSURL = NSURL.fileURLWithPath(path as String)
        self.kmlParser = KMLParser.init(URL: url)
        self.kmlParser.parseKML()
        
        // Add all of the MKOverlay objects parsed from the KML file to the map.
        let overlays:NSArray = self.kmlParser.overlays
        self.overlays = overlays
        self.mapView.addOverlays(overlays as! [MKOverlay])
        
        // Add all of the MKAnnotation objects parsed from the KML file to the map.
        let annotations:NSArray = self.kmlParser.points
        self.annotations = annotations
        self.mapView.addAnnotations(annotations as! [MKAnnotation])
        
        // Walk the list of overlays and annotations and create a MKMapRect that
        // bounds all of them and store it into flyTo.
        
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
    
    
    func loadViewFromNib() -> UIView {
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "TrailDetailsViewController", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int
    {
        if delegate != nil{
            items.removeAll()
            items.appendContentsOf(delegate!.getTrailsArray() as! [FIRDataSnapshot])
            if items.count > 0{
                if carousel.currentItemIndex < 0{
                    self.updateBasicInfo(0)
                }else {
                    self.updateBasicInfo(carousel.currentItemIndex)
                }
            }
            return items.count
        }
        return 0
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView
    {
        
        var card:TrailCard
        
        //create new view if no view is available for recycling
        if (view == nil)
        {
            card = TrailCard(frame: CGRect(x: 0, y: 0, width: 200, height: 300))
            
            //don't do anything specific to the index within
            //this `if (view == nil) {...}` statement because the view will be
            //recycled and used with other index values later
        }
        else
        {
            //get a reference to the label in the recycled view
            card  = view as! TrailCard
        }
        
        let trailCardInfo = items[index]
        card.trailCode.text = trailCardInfo.value!["code"] as? String
        card.trailName.text = trailCardInfo.value!["name"] as? String
        

        card.trailImagePreview.tag = Int(trailCardInfo.key)!
        let cachedImage = MyImageCache.sharedCache.objectForKey(
            trailCardInfo.key) as? UIImage
        
        if cachedImage == nil {
            card.trailImagePreview.contentMode = UIViewContentMode.Center
            card.trailImagePreview.image = UIImage.init(named: "imagePlaceHolder")
            let storageRef = storage.referenceForURL("gs://trails-21a06.appspot.com")
            let islandRef = storageRef.child("images/preview/\(trailCardInfo.key).png")
            
            islandRef.dataWithMaxSize(1 * 1024 * 1024 * 1024) { (data, error) -> Void in
                if (error != nil) {
                    // Uh-oh, an error occurred!
                } else {
                    // Data for "images/island.jpg" is returned
                    let islandImage: UIImage! = UIImage(data: data!)
                    if card.trailImagePreview.tag == Int(trailCardInfo.key)!{
                        card.trailImagePreview.contentMode = UIViewContentMode.ScaleAspectFill
                        
                        card.trailImagePreview.image = islandImage
                    }
                    MyImageCache.sharedCache.setObject(
                        islandImage,
                        forKey: trailCardInfo.key,
                        cost: data!.length)
                    
                }
            }
        }else{
            card.trailImagePreview.contentMode = UIViewContentMode.ScaleAspectFill
            card.trailImagePreview.image = cachedImage
        }
        
        
        let storageRef = storage.referenceForURL("gs://trails-21a06.appspot.com")
        let trailKmlRef = storageRef.child("trailsKml/\(trailCardInfo.key).kml")
        trailKmlRef.dataWithMaxSize(1 * 1024 * 1024 * 1024) { (data, error) -> Void in
            if (error != nil) {
                // Uh-oh, an error occurred!
            } else {
                let trailKML:NSData = data!
                let filename = self.getDocumentsDirectory().stringByAppendingPathComponent("\(trailCardInfo.key).kml")
                trailKML.writeToFile(filename, atomically: true)
//                self.parseKMLandCreateMap(filename)
            }
        }

        
        
        //set item label
        //remember to always set any properties of your carousel item
        //views outside of the `if (view == nil) {...}` check otherwise
        //you'll get weird issues with carousel item content appearing
        //in the wrong place in the carousel
        
        card.layer.shadowColor = UIColor.grayColor().CGColor
        card.layer.shadowOpacity = 2
        card.layer.shadowOffset = CGSizeZero
        card.layer.shadowRadius = 15
        
        
        return card
    }
    
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func carousel(carousel: iCarousel, didSelectItemAtIndex index: Int) {
        if carousel.currentItemIndex != index{
            self.updateBasicInfo(index)
        }
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel) {
        if carousel.currentItemIndex >= 0{
            self.updateBasicInfo(carousel.currentItemIndex)
        }
    }
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat
    {
        if (option == .Spacing)
        {
            return value * 14
        }
        
        if (option == .Angle)
        {
            return value * 0.087
        }
        return value
    }
    
    private func updateBasicInfo(arrayIndex:Int){
        let trailCardInfo = items[arrayIndex]
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.descriptionTextView.alpha = 0.0
            self.distanceLabel.alpha = 0.0
            self.durationLabel.alpha = 0.0
            self.mapView.alpha = 0.0
            }, completion: {
                (finished: Bool) -> Void in
                
                self.descriptionTextView.text = trailCardInfo.value!["description"] as? String
                let stringDuration = trailCardInfo.value!["duration"] as? Double
                let stringDistance = trailCardInfo.value!["distance"] as? Double
                let difficulty = trailCardInfo.value!["difficulty"] as? Int
                self.trailName = (trailCardInfo.value!["name"] as? String)!
                self.trailCode = (trailCardInfo.value!["code"] as? String)!
                self.trailRef = trailCardInfo.key
                
                self.setDificultyImageGraph(difficulty!)
                
                self.distanceLabel.text = "\(String(stringDistance!)) km"
                
                let aString: String = String(stringDuration!)
                let newString = aString.stringByReplacingOccurrencesOfString(".", withString: "h")
                self.durationLabel.text = newString
                
                let sizeThatFitsTextView = self.descriptionTextView.sizeThatFits(CGSizeMake(self.descriptionTextView.frame.width, CGFloat.max))
                self.TextViewHeightConstraint.constant = sizeThatFitsTextView.height;

                
                let storageRef = self.storage.referenceForURL("gs://trails-21a06.appspot.com")
                let trailKmlRef = storageRef.child("trailsKml/\(trailCardInfo.key).kml")
                trailKmlRef.dataWithMaxSize(1 * 1024 * 1024 * 1024) { (data, error) -> Void in
                    if (error != nil) {
                        // Uh-oh, an error occurred!
                    } else {
                        let trailKML:NSData = data!
                        let filename = self.getDocumentsDirectory().stringByAppendingPathComponent("\(trailCardInfo.key).kml")
                        trailKML.writeToFile(filename, atomically: true)
                        //                self.parseKMLandCreateMap(filename)
                    }
                }
                
                let filename = self.getDocumentsDirectory().stringByAppendingPathComponent("\(trailCardInfo.key).kml")
                self.parseKMLandCreateMap(filename)
                
                
                // Fade in
                UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                    self.descriptionTextView.alpha = 1.0
                    self.distanceLabel.alpha = 1.0
                    self.durationLabel.alpha = 1.0
                    self.mapView.alpha = 1.0
                    }, completion: nil)
        })
    }
    
    func onRefresh()
    {
        delegate!.getUpdateData()
        refreshControl.endRefreshing()
    }
    
    @IBAction func startTrailActivity(sender: AnyObject) {
        let userPoint:MKMapPoint = MKMapPointForCoordinate(userCurrentLocation.coordinate)
        let mapRect:MKMapRect = mapView.visibleMapRect;
        let insideMap:Bool  = MKMapRectContainsPoint(mapRect, userPoint);
        if (insideMap){
            if (comeFrom.isEqualToString(Constants.nearbyController)){
                let vc = self.delegate as! NearbyViewController
                vc.goToTrailActivity(trailRef, code: trailCode, name: trailName,annorations: annotations,overlays: overlays)
            }else if (comeFrom == Constants.singleDetailController){
                let vc = self.delegate as! SingleTrailDetail
                vc.goToTrailActivity()
            }
        }else {
            let alert = UIAlertController(title: "Informação", message: "Deve estar próximo do percurso para poder fazer o seu registo", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        }
    
    }

    func setDificultyImageGraph(level:Int){
        switch level {
        case 1:
            self.dificultyLevelImage.image = UIImage.init(named: "dificult1")
        case 2:
            self.dificultyLevelImage.image = UIImage.init(named: "dificult2")
        case 3:
            self.dificultyLevelImage.image = UIImage.init(named: "dificult3")
        case 4:
            self.dificultyLevelImage.image = UIImage.init(named: "dificult4")
        case 5:
            self.dificultyLevelImage.image = UIImage.init(named: "dificult5")
        default:
            self.dificultyLevelImage.image = UIImage.init(named: "dificult0")
        }
        
    }
    
// MARK: MKMapViewDelegate

    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        return self.kmlParser.rendererForOverlay(overlay)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        return self.kmlParser.viewForAnnotation(annotation)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        let geoCoder = CLGeocoder()
        userCurrentLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        
        geoCoder.reverseGeocodeLocation(userCurrentLocation) { (placemarks, error) in
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            var cityNameString = "  Localização atual: "
            if let city = placeMark.addressDictionary!["City"] as? NSString {
                cityNameString.appendContentsOf(city as String)
            }
            
            let attachment:NSTextAttachment = NSTextAttachment()
            attachment.image = UIImage.init(named: "IamHere")
            let attachmentString:NSAttributedString = NSAttributedString(attachment: attachment)
            let cityName:NSAttributedString = NSAttributedString(string: cityNameString)
            let teste:NSMutableAttributedString = NSMutableAttributedString()
            teste.appendAttributedString(attachmentString)
            teste.appendAttributedString(cityName)
            self.cityNameLabel.attributedText = teste
            self.locationManager.stopUpdatingLocation()
        }
        
    }

}

class MyImageCache {
    
    static let sharedCache: NSCache = {
        let cache = NSCache()
        cache.name = "MyImageCache"
        cache.countLimit = 20 // Max 20 images in memory.
        cache.totalCostLimit = 20*1024*1024 // Max 10MB used.
        return cache
    }()
}

