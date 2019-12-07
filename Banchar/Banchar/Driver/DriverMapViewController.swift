
import UIKit
import GoogleMaps

class DriverMapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    @IBOutlet weak var btnPickup: DesignableButton!
    @IBOutlet weak var cView: UIView!
    var locationManager = CLLocationManager()
    var mapView: GMSMapView? = nil
    var pickedUp = false
    var pickMarker = GMSMarker(position: userDestination)
    var destMarker = GMSMarker(position: userDestination)
    var pick: CLLocationCoordinate2D? = nil
    var dest: CLLocationCoordinate2D? = nil
    var req: String = "0"
    var checkTimer : Timer? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let b = self.btnPickup
        
        
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 18)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        self.view = mapView!
        self.view.addSubview(b!)
        self.btnPickup.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 32).isActive = true
        self.btnPickup.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -32).isActive = true
        self.btnPickup.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -32).isActive = true
        mapView!.isMyLocationEnabled = true
        mapView?.delegate = self
        //Location Manager code to fetch current location
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()

        if let pick = pick {
            let markerImage = UIImage(named: "pick")!
            let markerView = UIImageView(image: markerImage)
            pickMarker.iconView = markerView
            pickMarker.map = mapView
            pickMarker.position = pick
        }
        if let dest = dest {
            let markerImage = UIImage(named: "tracking")!
            let markerView = UIImageView(image: markerImage)
            destMarker.iconView = markerView
            destMarker.map = mapView
            destMarker.position = dest
        }

        _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (_) in
            let request = APIRequest()
            request.target = Target.updateLocation(x: "\(userOrigin?.coordinate.latitude ?? 0)", y: "\(userOrigin?.coordinate.longitude ?? 0)")
            request.onSuccess = {
                let str = String(data: request.rawResponse!, encoding: .utf8)!
                print(str)
//                    let alert = UIAlertController(title: "Error", message: str, preferredStyle: .alert)
//                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
//                    alert.addAction(ok)
//                    self.present(alert, animated: true, completion: nil)

            }
//            request.onFail = {
//                let alert = UIAlertController(title: "Error", message: "Something Went Wrong", preferredStyle: .alert)
//                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
//                alert.addAction(ok)
//                self.present(alert, animated: true, completion: nil)
//            }
            request.start()
        })
        checkTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (_) in
            print("TIMER CALLED")
            let request = APIRequest()
            request.target = Target.checkStatus(id: self.req)
            request.onSuccess = {
                let str = String(data: request.rawResponse!, encoding: .utf8)!
                print(str)
                let status = str.components(separatedBy: "\"status\":\"")[1].components(separatedBy: "\"")[0]
                if status == "2" {
                    print("TIMER INVALIDATED")
                    self.checkTimer?.invalidate()
                    let alert = UIAlertController(title: "Ride Ended", message: nil, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default) { (_) in
                        self.dismiss(animated: true, completion: nil)
                    }
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                    
                    
                }
            }
            request.start()
        })
        
        
        _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (_) in
            self.hideRoutes()
            self.showRoutes()
        })
    }
    
    
    var singleLine : GMSPolyline = GMSPolyline()
    func hideRoutes() { singleLine.map = nil }
    func showRoutes() {
        guard let pick = pick, let dest = dest, let userOrigin = userOrigin else { return }
        let destLatitude = pickedUp ? dest.latitude : pick.longitude
        let destLongitude = pickedUp ? dest.latitude : pick.longitude
        let url = NSURL(string: "\("https://maps.googleapis.com/maps/api/directions/json")?origin=\(userOrigin.coordinate.latitude),\(userOrigin.coordinate.longitude)&destination=\(destLatitude),\(destLongitude)&sensor=true&key=\(googleAPIKey)")
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            do {
                if data != nil {
                    let dic = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! [String: AnyObject]
                    let status = dic["status"] as! String
                    var routesArray: String!
                    if status == "OK" {
                        print("status  ok")
                        routesArray = ((((dic["routes"]!as! [Any])[0] as! [String: Any])["overview_polyline"] as! [String: Any])["points"] as! String)
                    } else {
                    }

                    DispatchQueue.main.async {
                        if let routesArray = routesArray {
                            let path = GMSPath.init(fromEncodedPath: routesArray)
                            self.singleLine = GMSPolyline.init(path: path)
                            self.singleLine.strokeWidth = 6.0
                            self.singleLine.strokeColor = .blue
                            self.singleLine.map = self.mapView
                        }
                    }

                } else {
                    print("nil data")
                }
            } catch {
                print("Error")
            }
        }

        task.resume()
    }
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let location = locations.last
        userOrigin = location

        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)

        self.mapView?.animate(to: camera)

        //Finally stop updating location otherwise it will come again and again in this delegate
        //self.locationManager.stopUpdatingLocation()
    }

    @IBAction func btnPickedUpAction(_ sender: Any) {
        pickedUp = true
        btnPickup.isHidden = true
    }
}
