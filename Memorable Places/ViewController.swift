//
//  ViewController.swift
//  Memorable Places
//
//  Created by Robson Cassol on 28/07/15.
//  Copyright (c) 2015 cassol. All rights reserved.
//

import UIKit
import MapKit


class ViewController: UIViewController, CLLocationManagerDelegate {

    var manager: CLLocationManager!
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        if activePlace == -1 {
            
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
            
        } else {
            
            let latitude = NSString(string: places[activePlace]["lat"]!).doubleValue
            let longitude = NSString(string: places[activePlace]["lon"]!).doubleValue
            var newCoordinate = CLLocationCoordinate2DMake(latitude, longitude)
            
            centralizeMapOn(newCoordinate)
            var title = places[activePlace]["name"]!
            createAnAnotation(newCoordinate, title: title)
            
        }
        
        var uilpgr = UILongPressGestureRecognizer(target: self, action: "action:")
        uilpgr.minimumPressDuration = 1.0
        map.addGestureRecognizer(uilpgr)

    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {

        var userLocation:CLLocation = locations[0] as! CLLocation
        
        centralizeMapOn(userLocation.coordinate)
        
    }
    
    func centralizeMapOn(location:CLLocationCoordinate2D){
        var latDelta:CLLocationDegrees = 0.01
        var lonDelta:CLLocationDegrees = 0.01
        var span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        var region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        map.setRegion(region , animated: true)
    }
    
    
    func action(gestureRecognizer:UIGestureRecognizer){
        
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
        
        
            var touchPoint = gestureRecognizer.locationInView(self.map)
        
            var newCoordinate: CLLocationCoordinate2D = map.convertPoint(touchPoint, toCoordinateFromView: self.map);
            
            var location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                
                var title = ""
                
                if error == nil {
                    
                    if let p = CLPlacemark(placemark: placemarks?[0] as! CLPlacemark) {
                        
                        var subThoroughfare:String = ""
                        var thoroughfare:String = ""
                        
                        if p.subThoroughfare != nil {
                            
                            subThoroughfare = p.subThoroughfare
                            
                        }
                        
                        if p.thoroughfare != nil {
                            
                            thoroughfare = p.thoroughfare
                            
                        }
                        
                        title = "\(subThoroughfare) \(thoroughfare)"
                        
                    }
                    
                    if title.isEmpty {
                        
                        title = "Added \(NSDate())"
                        
                    }
                    
                    
                    places.append(["name":title, "lat":newCoordinate.latitude.description, "lon": newCoordinate.longitude.description])
                    
                    println(places)
                }
                
            })
        
        
            createAnAnotation(newCoordinate, title:"Title")
            
            
        }
    }
    
    func createAnAnotation(coordinate:CLLocationCoordinate2D, title:String) {
        
        var annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinate
        
        annotation.title = title
        
        
        map.addAnnotation(annotation)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

 

}

