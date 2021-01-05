//
//  ViewMap.swift
//  GPM
//
//  Created by Edzko Smid on 1/5/21.
//  Copyright © 2021 com.tecllc. All rights reserved.
//

import UIKit
import MapKit
//import CoreLocation

class ViewMap: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var GPMMap: MKMapView!
    //let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let initialLocation = CLLocation(latitude: 42.8, longitude: -83.27)
        GPMMap.centerToLocation(initialLocation)
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 100000)
        GPMMap.setCameraZoomRange(zoomRange, animated: true)
        //locationManager.delegate = self
        //locationManager.startUpdatingHeading()
        
        GPMMap.camera.heading = 90
        GPMMap.setCamera(GPMMap.camera,animated:true)
    }

    //func locationManager(_ manager:CLLocationManager, didUpdateHeading newHeading: CLHeading)
    //{
    //    GPMMap.camera.heading = newHeading.magneticHeading
    //    GPMMap.setCamera(GPMMap.camera, animated:true)
    //}
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
private extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 1000
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}
