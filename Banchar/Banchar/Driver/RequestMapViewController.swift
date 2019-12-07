//
//  RequestMapViewController.swift
//  Banchar
//
//  Created by Forat Bahrani on 12/7/19.
//  Copyright © 2019 Forat Bahrani. All rights reserved.
//

import UIKit
import GoogleMaps

class RequestMapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    var req: Request? = nil
    var mapView: GMSMapView? = nil

    override func viewDidLoad() {
        super.viewDidLoad()


    }

    func setup() {
        let camera = GMSCameraPosition.camera(withLatitude: Double(req!.pickup_x)! - 0.001, longitude: Double(req!.pickup_y)! - 0.002, zoom: 17)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView!
        mapView!.isMyLocationEnabled = false
        mapView?.delegate = self
        let loc = CLLocationCoordinate2D(latitude: Double(req!.pickup_x)!, longitude: Double(req!.pickup_y)!)
        let destMarker = GMSMarker(position: loc)
        destMarker.map = mapView
        let markerImage = UIImage(named: "tracking")!
        let markerView = UIImageView(image: markerImage)
        destMarker.iconView = markerView
        destMarker.map = mapView
        destMarker.position = loc
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.mapView?.camera = GMSCameraPosition(target: loc, zoom: 12)
        }
    }

}
