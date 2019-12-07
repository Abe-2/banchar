
import UIKit
import GoogleMaps

var userDestination: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: 0)!, longitude: CLLocationDegrees(exactly: 0)!)
var userOrigin: CLLocation? = nil



class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    var locationManager = CLLocationManager()
    var mapView: GMSMapView? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView!
        mapView!.isMyLocationEnabled = true
        mapView?.delegate = self
        //Location Manager code to fetch current location
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()

        destMarker.map = mapView

        _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (_) in
            if let driverLoc = driverLocation {
                if let x = Double(driverLoc.location_x ?? "0"), let y = Double(driverLoc.location_y ?? "0") {
                    let markerImage = UIImage(named: "taxi")!
                    let markerView = UIImageView(image: markerImage)
                    self.driverMarker.iconView = markerView
                    self.driverMarker.map = self.mapView
                    self.driverMarker.position = CLLocationCoordinate2D(latitude: x, longitude: y)
                }
            } else {
                self.driverMarker.map = nil
            }
            if resetMap {
                self.driverMarker.map = nil
                self.destMarker.map = nil
                resetMap = false
            }
        })

    }

    var singleLine : GMSPolyline = GMSPolyline()
    func hideRoutes() { singleLine.map = nil }
    func showRoutes() {
        let destLatitude = userDestination.latitude
        let destLongitude = userDestination.longitude
        let url = NSURL(string: "\("https://maps.googleapis.com/maps/api/directions/json")?origin=\(userOrigin?.coordinate.latitude ?? 29.31948031),\(userOrigin?.coordinate.longitude ?? 48.05445906)&destination=\(destLatitude),\(destLongitude)&sensor=true&key=\(googleAPIKey)")
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
                        let path = GMSPath.init(fromEncodedPath: routesArray!)
                        self.singleLine = GMSPolyline.init(path: path)
                        self.singleLine.strokeWidth = 6.0
                        self.singleLine.strokeColor = .blue
                        self.singleLine.map = self.mapView
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
        self.locationManager.stopUpdatingLocation()
    }

    var destMarker = GMSMarker(position: userDestination)
    var driverMarker = GMSMarker(position: userDestination)

    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        notify(name: .closeKeyboard)
    }

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        notify(name: .closeKeyboard)
    }
}

