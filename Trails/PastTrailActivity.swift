//
//  PastTrailActivity.swift
//  Trails
//
//  Created by Rui Policarpo on 13/08/16.
//  Copyright © 2016 nExp. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import HealthKit


class PastTrailActivity: UIViewController{
    var run: Run!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var trailNameLabel: UILabel!
    @IBOutlet weak var trailCodeLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var noMapView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.mapView.layer.cornerRadius = 10
    }
    
    func configureView() {
        let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: run.distance.doubleValue)
        distanceLabel.text = "Distância: " + distanceQuantity.description
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateLabel.text = dateFormatter.stringFromDate(run.timestamp)
        
        let secondsQuantity = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: run.duration.doubleValue)
        timeLabel.text = "Duração: " + secondsQuantity.description
        
//        let paceUnit = HKUnit.secondUnit().unitDividedByUnit(HKUnit.meterUnit())
//        let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: run.duration.doubleValue / run.distance.doubleValue)
//        paceLabel.text = "Pace: " + paceQuantity.description
        
        trailNameLabel.text = run.trailName as String
        trailCodeLabel.text = run.trailCode as String
        trailCodeLabel.backgroundColor = kGR1
        trailCodeLabel.layer.cornerRadius = 10
        trailCodeLabel.layer.masksToBounds = true
        pointsLabel.text = "Folhas: " + String(Int((run.points as Double)*10))
        loadMap()
    }
    
    func mapRegion() -> MKCoordinateRegion {
        let initialLoc = run.locations.firstObject as! Location
        
        var minLat = initialLoc.latitude.doubleValue
        var minLng = initialLoc.longitude.doubleValue
        var maxLat = minLat
        var maxLng = minLng
        
        let locations = run.locations.array as! [Location]
        
        for location in locations {
            minLat = min(minLat, location.latitude.doubleValue)
            minLng = min(minLng, location.longitude.doubleValue)
            maxLat = max(maxLat, location.latitude.doubleValue)
            maxLng = max(maxLng, location.longitude.doubleValue)
        }
        
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: (minLat + maxLat)/2,
                longitude: (minLng + maxLng)/2),
            span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.1,
                longitudeDelta: (maxLng - minLng)*1.1))
    }
    
    func polyline() -> MKPolyline {
        var coords = [CLLocationCoordinate2D]()
        
        let locations = run.locations.array as! [Location]
        for location in locations {
            coords.append(CLLocationCoordinate2D(latitude: location.latitude.doubleValue,
                longitude: location.longitude.doubleValue))
        }
        
        return MKPolyline(coordinates: &coords, count: run.locations.count)
    }
    
    func loadMap() {
        if run.locations.count > 0 {
            noMapView.hidden = true
            mapView.hidden = false
            
            // Set the map bounds
            mapView.region = mapRegion()
            
            // Make the line(s!) on the map
            let colorSegments = MulticolorPolylineSegment.colorSegments(forLocations: run.locations.array as! [Location])
            mapView.addOverlays(colorSegments)
        } else {
            // No locations were found!
            mapView.hidden = true
            noMapView.hidden = false
            UIAlertView(title: "Erro",
                        message: "Desculpe, esta caminhada não tem registos guardados",
                        delegate:nil,
                        cancelButtonTitle: "OK").show()
        }
    }
    @IBAction func closeViewAction(sender: AnyObject) {

        self.navigationController?.popViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - MKMapViewDelegate
extension PastTrailActivity: MKMapViewDelegate {
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if !overlay.isKindOfClass(MulticolorPolylineSegment) {
            return nil
        }
        
        let polyline = overlay as! MulticolorPolylineSegment
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = polyline.color
        renderer.lineWidth = 3
        return renderer
    }
}
