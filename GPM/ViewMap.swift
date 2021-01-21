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

class CarCustomAnnotation: MKPointAnnotation {
    var pinCustomImageName:String!
    var courseDegrees : Double! // Change The Value for Rotating Car Image Position
}

class MarkerAnnotationView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let annotation = newValue as? CarCustomAnnotation else { return }
            image = UIImage.init(named: annotation.pinCustomImageName)
        }
    }
}

class ViewMap: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var mainDlg: ViewController!
    var socketConnector:SocketDataManager!
    var longitude: Double = -83.271
    var latitude: Double = 42.7994
    var heading: Float?
    var timer = Timer()
    
    var pointAnnotation: CarCustomAnnotation!
    var pinAnnotationView: MKAnnotationView!
    let reuseIdentifier = "pin"
    var Location : CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 42.7 , longitude: -83.25)
    
    @IBOutlet weak var swNorthUp: UISwitch!
    @IBOutlet weak var GPMMap: MKMapView!
    //let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pointAnnotation = CarCustomAnnotation()
        pointAnnotation.pinCustomImageName = "max4"
        pointAnnotation.coordinate = Location!
        pinAnnotationView = MKAnnotationView(annotation: pointAnnotation, reuseIdentifier: reuseIdentifier)

        GPMMap.delegate = self
        GPMMap.addAnnotation(pinAnnotationView.annotation!)
        
        let initialLocation = CLLocation(latitude: 42.7, longitude: -83.25)
        GPMMap.centerToLocation(initialLocation)
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 100000)
        GPMMap.setCameraZoomRange(zoomRange, animated: true)
        //locationManager.delegate = self
        //locationManager.startUpdatingHeading()
        heading = 0.0
        longitude = 0.0
        latitude = 0.0
        GPMMap.camera.heading = 90
        GPMMap.setCamera(GPMMap.camera,animated:true)
        GPMMap.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: reuseIdentifier)
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            timer.invalidate()
            mainDlg.viewID = 1
        }
    }
    
    @objc func fireTimer() {
        let message = "G"
        socketConnector.send(message: message)
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
    func valDouble(buf: Array<UInt8>, start: Int) -> Double {
        var val : Double = 0.0
        var dbuf = [UInt8](repeating: 0, count: 8)
        for i in 0...7 {
            dbuf[i] = buf[i+start]
        }
        let _ = Swift.withUnsafeMutableBytes(of: &val, { dbuf.copyBytes(to: $0)} )
        return val
    }
    func valFloat(buf: Array<UInt8>, start: Int) -> Float {
        var val: Float = 0.0
        var fbuf = [UInt8](repeating: 0, count: 4)
        for i in 0...3 {
            fbuf[i] = buf[i+start]
        }
        let _ = Swift.withUnsafeMutableBytes(of: &val, { fbuf.copyBytes(to: $0)} )
        return val
    }
    func valInt16(buf: Array<UInt8>, start: Int) -> Int16 {
        var val: Int16 = 0
        var ibuf = [UInt8](repeating: 0, count: 2)
        for i in 0...1 {
            ibuf[i] = buf[i+start]
        }
        let _ = Swift.withUnsafeMutableBytes(of: &val, { ibuf.copyBytes(to: $0)} )
        return val
    }
       
    func update(message: Array<UInt8>) {
        /*
         struct {
         uint64_t time;
         double latitude;
         double longitude;
         float heading;
         float std;
         float Vpp;
         uint16_t posType;
         int16_t steer;
         int16_t brake;
         int16_t rpm;
         int16_t speed;
         int16_t gear;
         */
        
        if message.count<48 {
            return
        }
        latitude = valDouble(buf: message, start: 8)
        //lonField.text = String(format: "Longitude: %1.10f",lon)
        
        longitude = valDouble(buf: message, start: 16)
        //latField.text = String(format: "Latitude: %1.10f",lat)
        
        heading = 0.75*heading! + 0.25*valFloat(buf: message, start: 24)
       // headField.text = String(format: "Heading: %1.2f",heading)
        
        let std = valFloat(buf: message, start: 28)
        //stdField.text = String(format: "Std dev.: %1.3f",std)
        
        let vcc = valFloat(buf: message, start: 32)
        //vccField.text = String(format: "Power: %1.2f",vcc)
        
        let info = valInt16(buf: message, start: 36)
        //infoField.text = String(format: "Info: %d",info)
        
        Location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        GPMMap.setCenter(Location!, animated:true)
        
        GPMMap.setCamera(GPMMap.camera,animated:true)
        
        if swNorthUp.isOn {
            GPMMap.camera.heading = 0.0
            moveCar(Location!, heading: Double(heading!))
        }
        else {
            GPMMap.camera.heading = Double(heading!)
            moveCar(Location!, heading: 90.0)
        }
        
        
        
        //GPMMap.setCamera(GPMMap.camera, withDuration: 1, animationTimingFunction:
        //                    CAMediaTimingFunction(name:
        //                    CAMediaTimingFunctionName.easeInEaseOut))
        //)
        
    }

/*
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 4.0
            return polylineRenderer
        }
        return MKOverlayRenderer()
    }
*/
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotationView?.annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = false
        } else {
            annotationView?.annotation = annotation
            annotationView?.canShowCallout = false
        }
        let carImg = UIImage.init(named:pointAnnotation.pinCustomImageName)
        annotationView?.image = carImg!.resized(toScale: 0.5)
        return annotationView
    }
/*
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //Set PolyLine Between Source and Destinattion
        let polyline = MKPolyline(coordinates: [sourceCoordinate!,destinationCoordinate!], count: 2)
        mapView.add(polyline)
        pointAnnotation.courseDegrees =  self.getHeadingForDirectionFromCoordinate(sourceCoordinate!, toLoc: destinationCoordinate!)
         view.transform = CGAffineTransform(rotationAngle:CGFloat(pointAnnotation.courseDegrees))
         self.moveCar(self.destinationCoordinate!)
    }
 */
    //Inert Animation Duration and Destination Coordinate which you are getting from server.
    func moveCar(_ destinationCoordinate : CLLocationCoordinate2D, heading : Double) {
        UIView.animate(withDuration: 1, animations: {
            self.pointAnnotation.coordinate = destinationCoordinate
            self.pinAnnotationView.transform = CGAffineTransform(rotationAngle:CGFloat(heading))
        }, completion:  { [self] success in
            if success {
                // handle a successfully ended animation
                self.pointAnnotation.courseDegrees = heading
                self.pinAnnotationView.transform = CGAffineTransform(rotationAngle:CGFloat(self.pointAnnotation.courseDegrees))
                self.pointAnnotation.coordinate = destinationCoordinate
            } else {
                // handle a canceled animation, i.e move to destination immediately
                self.pointAnnotation.courseDegrees = heading
                self.pinAnnotationView.transform = CGAffineTransform(rotationAngle:CGFloat(self.pointAnnotation.courseDegrees))
                self.pointAnnotation.coordinate = destinationCoordinate
            }
        })
    }

/*
    func centerToLocation(
      _ location: CLLocation,
      regionRadius: CLLocationDistance = 1000
    ) {
      let coordinateRegion = MKCoordinateRegion(
        center: location.coordinate,
        latitudinalMeters: regionRadius,
        longitudinalMeters: regionRadius)
        GPMMap.setRegion(coordinateRegion, animated: true)
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

extension UIImage {
    func resized(toScale s: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width*s, height: size.height*s)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
