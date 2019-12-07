
import Foundation
import GoogleMaps
import UIKit

var updateDriverLocation = false {
    didSet {
        locationUpdater.start()
    }
}

var driverOrigin: CLLocation? = nil
let locationUpdater = LocationUpdater()
class LocationUpdater : NSObject, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var timer : Timer? = nil
    override init() {
        super.init()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        driverOrigin = locations.last
        print("driver origin updated")
    }
    
    func start() {
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (_) in
            guard let o = driverOrigin else { return }
            guard updateDriverLocation else { return }
            let request = APIRequest()
            let x = String(format: "%.4f", o.coordinate.latitude)
            let y = String(format: "%.4f", o.coordinate.longitude)
            request.target = Target.updateLocation(x: x, y: y)
            request.onFail = {
                print("failed: update driver location")
            }
            request.onSuccess = {
                print("driver location updated")
            }
            request.start()
        })
    }
    
    
}
