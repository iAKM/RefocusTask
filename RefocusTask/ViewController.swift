//
//  ViewController.swift
//  RefocusTask
//
//  Created by Achyut Kumar Maddela on 22/08/17.
//  Copyright © 2017 AKM. All rights reserved.
//

import UIKit
import GoogleMaps
import TGLParallaxCarousel


class ViewController: UIViewController {

    @IBOutlet weak var googleMaps: GMSMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var carouselView: TGLParallaxCarousel!
    
    var screenRect = CGRect()
    var locationManager = CLLocationManager()
    var polyline = GMSPolyline()
    var animationPolyline = GMSPolyline()
    var path = GMSPath()
    var animationPath = GMSMutablePath()
    var i: UInt = 0
    var timer: Timer!

    var uberTypes = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
       // setupCarousel()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        let camera = GMSCameraPosition.camera(withLatitude: 17.4265, longitude: 78.4511, zoom: 11.0)
        self.googleMaps.camera = camera
        self.googleMaps.isMyLocationEnabled = true
        self.googleMaps.settings.scrollGestures = true
        collectionViewProperties()

        uberTypes = ["UberPOOL", "UberGO", "UberX", "UberSUV"]

    }

    func createMarker(titleMarker: String, iconMarker: UIImage, latitude: CLLocationDegrees, longtitude: CLLocationDegrees) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)
        marker.title = titleMarker
        marker.icon = iconMarker
        marker.map = googleMaps
    }

    func drawPath(startLocation: CLLocation, endLocation: CLLocation)
    {
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"

        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&key=AIzaSyAOL7m7cP5u5JuwaU5zsbmXFPgRPtibKtM&mode=driving"

        APIServices.getUrlSession(url) { (response) in
            print(response)
            guard let response = response as? NSDictionary else {return}
            guard let routes = response["routes"] as? [NSDictionary] else {return}

                let route = routes[0]
                let routeOverViewPolyline = route["overview_polyline"] as! NSDictionary
                let points = routeOverViewPolyline["points"] as! String

                DispatchQueue.main.async {
                    self.path = GMSPath.init(fromEncodedPath: points)!
                    let polyline = GMSPolyline.init(path: self.path)
                    polyline.strokeWidth = 4
                    polyline.strokeColor = UIColor.black
                    polyline.map = self.googleMaps
                    self.fitAllMarkers(path: self.path)
                    self.timer = Timer.scheduledTimer(timeInterval: 0.020, target: self, selector: #selector(self.animatePolylinePath), userInfo: nil, repeats: true)

                }
        }
    }

    func animatePolylinePath() {
        if (self.i < self.path.count()) {
            self.animationPath.add(self.path.coordinate(at: self.i))
            self.animationPolyline.path = self.animationPath
            self.animationPolyline.strokeColor = UIColor(red: 0.937, green: 0.941, blue: 0.945, alpha: 1.00)
            self.animationPolyline.strokeWidth = 3
            self.animationPolyline.map = googleMaps
            self.i += 1
        }
        else {
            self.i = 0
            self.animationPath = GMSMutablePath()
            self.animationPolyline.map = nil
        }
    }

    func fitAllMarkers(path: GMSPath) {
        var bounds = GMSCoordinateBounds()
        for index in 1...path.count() {
            bounds = bounds.includingCoordinate(path.coordinate(at: index))
        }
        googleMaps.animate(with: GMSCameraUpdate.fit(bounds))
    }

}



extension ViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let pickupLoc = locations.last
        let dropLoc = CLLocation(latitude: 17.2403, longitude: 78.4294)
        createMarker(titleMarker: "Pickup Location", iconMarker: #imageLiteral(resourceName: "pickup_pin@1x"), latitude: (pickupLoc?.coordinate.latitude)!, longtitude: (pickupLoc?.coordinate.longitude)!)
        createMarker(titleMarker: "Drop Location", iconMarker: #imageLiteral(resourceName: "destination_pin@1x"), latitude: (dropLoc.coordinate.latitude), longtitude: (dropLoc.coordinate.longitude))
        drawPath(startLocation: pickupLoc!, endLocation: dropLoc)
        locationManager.stopUpdatingLocation()

    }
}

extension ViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        googleMaps.isMyLocationEnabled = true
        if gesture {
            mapView.selectedMarker = nil
        }
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        googleMaps.isMyLocationEnabled = true
        return false
    }

    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        googleMaps.isMyLocationEnabled = true
        googleMaps.selectedMarker = nil
        return false
    }

    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {

        let anchor = marker.position
        let point = mapView.projection.point(for: anchor)
        let infoLabel = UILabel(frame: CGRect(origin: point, size: CGSize(width: 60, height: 20)))
        infoLabel.layer.masksToBounds = true
        infoLabel.text = "Test"
        infoLabel.isHidden = false
        return infoLabel

    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionViewProperties() {
        collectionView.dataSource = self
        collectionView.delegate = self
        let nibName = UINib(nibName: "CarCell", bundle:nil)
        collectionView.register(nibName, forCellWithReuseIdentifier: "cell")
        collectionView.setItemsInRow(items: 3)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return uberTypes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CarCell
        cell.typeLabel.text = uberTypes[indexPath.row]
        return cell
    }
}

extension UICollectionView {
    func setItemsInRow(items: Int) {
        if let layout = self.collectionViewLayout as? UICollectionViewFlowLayout {
            let contentInset = self.contentInset
            let itemsInRow: CGFloat = CGFloat(items);
            let innerSpace = layout.minimumInteritemSpacing * (itemsInRow - 1.0)
            let insetSpace = contentInset.left + contentInset.right + layout.sectionInset.left + layout.sectionInset.right
            let width = floor((frame.width - insetSpace - innerSpace) / itemsInRow);
            layout.itemSize = CGSize(width: width, height: width)
        }
    }
}

