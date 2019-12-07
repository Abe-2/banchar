
import UIKit
import GoogleMaps
import Cosmos

var driverLocation: DriverLocation? = nil
var waiting = false
var resetMap = false
var requested = false
var closeit = false
var drivers: [Driver] = []
var driverIndex = 0


class HomeViewController: UIViewController {

    @IBOutlet weak var desc: UITextField!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var infoBox: DesignableButton!

    @IBOutlet weak var btnLetsGo: DesignableButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var reqId: String? = nil
    var latestReq: Timer? = nil
    var driverIdToTrack: String? = nil
    var timePicker = UIDatePicker()
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.tap { (_) in
            self.view.endEditing(true)
        }
        KeyboardAvoiding.avoidingView = inputView
        doWhen(.fareChanged) {
            UIView.animate(withDuration: 0.3) {
                self.infoBox.alpha = 1
            }
        }

//        _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (_) in
//            guard let reqId = self.reqId else { return }
//            let request = APIRequest(withTarget: Target.checkStatus(id: reqId))
//            request.onSuccess = {
//                let str = String(data: request.rawResponse!, encoding: .utf8)!
//                if str == "pending" {
//                    print("pending")
//                    self.btnLetsGo.setTitle("Pending", for: .normal)
//                    waiting = true
//                } else {
//                    do {
//                        let info = try JSONDecoder().decode(DriverInfo.self, from: request.rawResponse!)
//                        if info.driver_id != "0" {
//                            waiting = true
//                            self.driverInfo = info
//                        }
//                    } catch {
//                        request.onFail?()
//                        waiting = false
//                    }
//                }
//            }
//            request.onFail = {
//                waiting = false
//
//                self.indicator.stopAnimating()
//                let alert = UIAlertController(title: "Error", message: "Something went wrong. Cannot track your order. 1", preferredStyle: .alert)
//                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
//                alert.addAction(ok)
//                if self.presentedViewController == nil { // avoids repetitive alerts
//                    self.present(alert, animated: true, completion: nil)
//                }
//            }
//            request.start()
//        })

        _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (_) in
            guard let driverInfo = self.driverIdToTrack else { return }
            let request = APIRequest(withTarget: Target.getDriverLocation(driverId: driverInfo))
            request.processJson = false
            request.onSuccess = {
                do {
                    driverLocation = try JSONDecoder().decode(DriverLocation.self, from: request.rawResponse!)
                    self.btnCancel.isHidden = true
                    self.btnCancel.alpha = 0
                    self.indicator.stopAnimating()
                    waiting = true
                } catch {
                    request.onFail?()
                }
            }
            request.onFail = {
                waiting = false
                self.indicator.stopAnimating()
                let alert = UIAlertController(title: "Error", message: "Something went wrong. Cannot track your order. 2", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                if self.presentedViewController == nil { // avoids repetitive alerts
                    self.present(alert, animated: true, completion: nil)
                }
            }
            request.start()
        })

//
//        latestReq = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (_) in
//            let request = APIRequest(withTarget: Target.getLastRequest())
//            request.onSuccess = {
//                let str = String(data: request.rawResponse!, encoding: .utf8)!
//                if str.contains("id") {
//                    let status = str.components(separatedBy: "\"status\":\"")[1].components(separatedBy: "\"")[0]
//                    guard status == "1" else {
//                        return
//                    }
//                    waiting = true
//                    self.reqId = str.components(separatedBy: "\"id\":\"")[1].components(separatedBy: "\"")[0]
//                    self.infoBox.alpha = 1
//                    self.btnLetsGo.alpha = 0.3
//                    self.btnLetsGo.isEnabled = false
//                    self.btnCancel.isHidden = false
//                    self.btnCancel.alpha = 1
//                    self.btnCancel.isEnabled = true
//                    self.latestReq?.invalidate()
//                } else {
//                    waiting = false
//                }
//            }
//            request.start()
//        })

//        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
//            guard self.reqId == nil else { return }
//            guard let subscribed = Keychain.get("subscribed") else { return }
//            guard subscribed == "1" else { return }
//            guard requested == false else { return }
//            let d = Int(Date().dateString(format: "yyyyMMdd"))!
//            let e = Int(Keychain.get("expiry")!)!
//            let t = String(Date().dateString(format: "HH:mm"))
//            let rt = Keychain.get("time")!
//            guard t == rt else { return }
//            guard d <= e else { return }
//
//            userDestination.latitude = Double(Keychain.get("destX")!)!
//            userDestination.longitude = Double(Keychain.get("destY")!)!
//            requested = true
//            self.btnLetsGoAction(self.btnLetsGo)
//        })


        timePicker.datePickerMode = .time

        doWhen(.closeKeyboard) {
            self.view.endEditing(true)
        }
    }



    @IBAction func btnLetsGoAction(_ sender: Any) {
        indicator.startAnimating()
        btnLetsGo.alpha = 0.3
        btnLetsGo.isEnabled = false

        let request = APIRequest()
        request.target = Target.createRequest(desc: desc.text ?? "")
        request.onSuccess = {
            let requestID = request.response.payload?.requestID ?? "0"
            let driverReq = APIRequest()
            driverReq.target = Target.getDrivers()
            driverReq.onSuccess = {
                drivers = driverReq.response.payload?.drivers ?? []
                drivers = drivers.sorted(by: { first, second in

                    let pickX = userOrigin!.coordinate.latitude
                    let pickY = userOrigin!.coordinate.longitude

                    let diffX1 = abs(pickX - Double(first.location_x ?? "0")!)
                    let diffY1 = abs(pickY - Double(first.location_y ?? "0")!)
                    let dist1 = sqrt(pow(diffX1, 2) + pow(diffY1, 2))

                    let diffX2 = abs(pickX - Double(second.location_x ?? "0")!)
                    let diffY2 = abs(pickY - Double(second.location_y ?? "0")!)
                    let dist2 = sqrt(pow(diffX2, 2) + pow(diffY2, 2))

                    return dist1 < dist2
                })
                driverIndex = 0

                self.askDriver(reqest: requestID, driver: drivers[driverIndex].id)

            }
            driverReq.onFail = {
                self.indicator.stopAnimating()
                request.popErrorUp(on: self)
                self.btnLetsGo.alpha = 1
                self.btnLetsGo.isEnabled = true
            }
            driverReq.start()
        }
        request.onFail = {
            self.indicator.stopAnimating()
            request.popErrorUp(on: self)
            self.btnLetsGo.alpha = 1
            self.btnLetsGo.isEnabled = true
        }
        request.start()


    }
    @IBAction func btnCancelAction(_ sender: Any) {
        guard let reqId = self.reqId else { return }
        let alert = UIAlertController(title: "Cancel Request?", message: "Are you sure to cancel your request? ", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .destructive) { (_) in
            self.cancelRequest(id: reqId)
        }
        let no = UIAlertAction(title: "No", style: .default, handler: nil)
        alert.addAction(yes)
        alert.addAction(no)
        self.present(alert, animated: true, completion: nil)
    }

    func askDriver(reqest: String, driver: String) {
        let req = APIRequest()
        req.target = Target.askDriver(driver: driver, request: reqest)
        req.onSuccess = {
            self.checkStatus(request: reqest)
        }
        req.onFail = {
            print("\(driverIndex) - \(drivers.count)")
            driverIndex = 1
            if driverIndex == drivers.count {
                print("Hello !")
                // TODO: cancel request
                self.present(title: "No Drivers", message: "No Drivers have Accepted your request.", actions: [UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (_) in
                    self.cancelRequest(id: reqest)
                })])
            } else {
                //self.askDriver(reqest: reqest, driver: drivers[driverIndex].id)
            }
        }
        req.start()
    }

    var oldStat = "0"
    func checkStatus(request: String) {
        self.reqId = request
        let req = APIRequest(withTarget: Target.checkStatus(id: request))
        req.onSuccess = {
            let status = req.response.payload?.status
            if status == "0" {
                self.oldStat = "0"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.checkStatus(request: request)
                }
                self.btnCancel.isHidden = false
                self.btnCancel.alpha = 1
            } else if status == "1" {
                // accepted
                self.driverIdToTrack = drivers[driverIndex].id
                self.btnCancel.isHidden = true
                self.btnCancel.alpha = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.checkStatus(request: request)
                }
            } else if status == "2" {
                // done
                self.doneRequest(driver: drivers[driverIndex].id)
            } else if status == "3" {
                // canceled
            } else if status == "4" {
                self.btnCancel.isHidden = false
                self.btnCancel.alpha = 1
                if status != self.oldStat {
                    driverIndex += 1
                    self.oldStat = status ?? "0"
                    if driverIndex == drivers.count {
                        // TODO: cancel request
                        print("Hello !")
                        self.present(title: "No Drivers", message: "No Drivers have Accepted your request.", actions: [UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (_) in
                            self.cancelRequest(id: id)
                        })])
                    } else {
                        self.askDriver(reqest: request, driver: drivers[driverIndex].id)
                    }
                }

            }
            self.oldStat = status ?? "0"
        }
        req.onFail = {
            req.popErrorUp(on: self)
        }
        req.start()
    }
    
    func doneRequest(driver: String) {
        let alert = UIAlertController(title: "Service done", message: "How do you want to pay?", preferredStyle: .alert)
        let credit = UIAlertAction(title: "Credit card", style: .default) { (_) in
            let cards = VCs.ccs()
            cards.handler = {
                self.showRating(driver: driver)
            }
            self.present(cards, animated: true)
        }
        let cash = UIAlertAction(title: "Cash", style: .default, handler: { _ in
            self.showRating(driver: driver)
        })
        alert.addAction(credit)
        alert.addAction(cash)
        self.present(alert, animated: true, completion: nil)
    }
    
    let ratingView = CosmosView()
    func showRating(driver: String) {
        //Alert for the rating
        let alert = UIAlertController(title: "\n\n", message: "", preferredStyle: UIAlertController.Style.alert)

        let customView = UIView(frame: CGRect(x: 0, y: 0, width: alert.view.frame.width, height: alert.view.frame.height))

        //The x/y coordinate of the rating view
        let xCoord = alert.view.frame.width/2 - 150 //(5 starts multiplied by 30 each, plus a 5 margin each / 2)
        let yCoord = CGFloat(25.0)

        ratingView.rating = 0.0
        ratingView.settings.starSize = 30
        ratingView.settings.emptyBorderColor = UIColor.black
        ratingView.settings.updateOnTouch = true
        ratingView.settings.fillMode = .full
        ratingView.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        ratingView.frame.origin.x = xCoord
        ratingView.frame.origin.y = yCoord

        customView.frame = CGRect(x: 0, y: 0, width: 300, height: 100)
        customView.addSubview(ratingView)
        customView.clipsToBounds = true

        alert.view.addSubview(customView)
        
        alert.addAction(UIAlertAction(title: "Save Rating", style: UIAlertAction.Style.default, handler: { UIAlertAction in
            self.rated(driver: driver)
        }))
        
        alert.addTextField(configurationHandler: nil)

//        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    func rated(driver: String) {
        let id = driver
        let req = APIRequest(withTarget: Target.getRating(driver: id))
        req.onSuccess = {
            let rating = Int((req.response.payload?.rating!)!) ?? 0
            var raters = Int((req.response.payload?.raters!)!) ?? 0
            
            print("rating \(rating)")
            print("rating \(raters)")
            
            let total  = rating*raters + Int(self.ratingView.rating)
            raters += 1
            
            let newRating = total/raters
            
            let req = APIRequest(withTarget: Target.rateDriver(driver: id, rating: String(newRating), raters: String(raters)))
            req.onSuccess = {
                self.present(title: "Done!", message: "Your rating has been added", actions: [UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)])
            }
            req.onFail = {
                req.popErrorUp(on: self)
            }
            req.start()
        }
        req.start()
        
        self.btnLetsGo.alpha = 1
        self.btnLetsGo.isEnabled = true
        self.btnCancel.isHidden = true
    }

    func cancelRequest(id: String) {
        let request = APIRequest()
        request.target = Target.cancelRequest(id: id)
        request.onSuccess = {
            driverIndex = 0
            self.indicator.stopAnimating()
            self.btnLetsGo.isEnabled = true
            self.indicator.stopAnimating()
            self.btnCancel.isHidden = true
            self.btnLetsGo.alpha = 1
            self.btnLetsGo.isEnabled = true
        }
        request.onFail = {
            self.indicator.stopAnimating()
            self.btnLetsGo.isEnabled = true
            request.popErrorUp(on: self)
        }
        request.start()

    }

}
