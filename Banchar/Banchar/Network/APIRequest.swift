

import Foundation
import UIKit


// set your targets here, eg: case addStudent = "Student/Add"
struct Target {
    static func login(phone: String, password: String) -> String {
        return "clientLogin.php?phone=\(phone)&pass=\(password)"
    }
    static func driverLogin(phone: String, password: String) -> String {
        return "driverLogin.php?phone=\(phone)&pass=\(password)"
    }
    static func register(name: String, phone: String, password: String, plate: String, car: String) -> String {
        return "clientRegister.php?name=\(name)&phone=\(phone)&pass=\(password)&plate=\(plate)&car=\(car)"
    }
    static func driverRegister(name: String, phone: String, password: String) -> String {
        return "driverRegister.php?name=\(name)&phone=\(phone)&pass=\(password)"
    }
    static func createRequest(desc: String) -> String {
        let pickX = userOrigin!.coordinate.latitude
        let pickY = userOrigin!.coordinate.longitude
        return "newRequest.php?id=\(id)&pick_x=\(pickX)&pick_y=\(pickY)&plate=\(plate)&img=\(img)&car=\(car)&desc=\(desc)"
    }

    static func getDrivers() -> String {
        return "client/getDrivers.php"
    }

    static func askDriver(driver: String, request: String) -> String {
        return "client/askDriver.php?driver=\(driver)&request=\(request)"
    }

    static func checkRequest() -> String {
        return "driver/checkRequest.php?driver=\(id)"
    }

    static func checkStatus(id: String) -> String {
        return "checkStatus.php?id=\(id)"
    }
    static func cancelRequest(id: String) -> String {
        return "cancelRequest.php?r=\(id)"
    }
    static func getRequests(type: String) -> String {
        return "getRequests.php?id=\(type)"
    }
    static func acceptsRequests(request: String, id: String) -> String {
        return "acceptRequest.php?id=\(id)&r=\(request)"
    }

    static func decline(req: String) -> String {
        return "driver/decline.php?id=\(id)&request=\(req)"
    }

    static func rateDriver(driver: String, rating: String, raters: String) -> String {
        return "client/rateDriver.php?driver=\(driver)&rating=\(rating)&raters=\(raters)"
    }
    
    //exabx.com/apps/taxi/api/
    static func updateLocation(x: String, y: String) -> String {
        return "updateDriverLocation.php?id=\(id)&x=\(x)&y=\(y)"
    }

    static func getDriverLocation(driverId: String) -> String {
        return "getDriverLocation.php?id=\(driverId)"
    }

    static func history() -> String {
        return "client/pickupHistory.php?client=\(id)"
    }
    
    static func endRide(req: String) -> String {
        return "endRide.php?r=\(req)"
    }
    
    static func getRating(driver: String) -> String {
        return "driver/getRating.php?driver=\(driver)"
    }

}

struct ClientRequest: Decodable {
    var id: String
    var pickup_x: String
    var pickup_y: String
    var dest_x: String
    var dest_y: String
    var fare: String
}
//{"status":"1","driver_id":"2"}
struct DriverInfo: Decodable {
    var status: String
    var driver_id: String
}

struct DriverLocation: Decodable {
    var location_x: String?
    var location_y: String?
}

struct APIResponse: Decodable {
    var status: String
    var message: String?
    var payload: Payload?
}

struct Payload: Decodable {
    var id: String?
    var plate_num: String?
    var car_type: String?
    var img: String?
    var drivers: [Driver]?
    var requestID: String?
    var status: String?
    var request: Request?
    var requests : [Request]?
    var rating: String?
    var raters: String?
}

struct Driver: Decodable {
    var id: String
    var name: String
    var email: String
    var rating: String
    var location_x: String?
    var location_y: String?
    var raters: String
}

struct Request: Decodable {
    var id: String
    var client_id: String
    var status: String
    var pickup_x: String
    var pickup_y: String
    var car_type: String
    var plate_num: String
    var description: String
    var img: String
    var date : String?
}

// the base request, handles required info
class BaseRequest: NSObject {

    static let baseUrl = "http://exabx.com/apps/banchar/api/"

    var target: String = ""
    var parameters: JSON = JSON([])
    var rawResponse: Data? = nil

    var onSuccess: (() -> ())? = nil
    var onFail: (() -> ())? = nil

    fileprivate var urlSession = URLSession()
}

class APIRequest: BaseRequest {
    var delay: Double = 0
    fileprivate var urlRequest: URLRequest? = nil
    var processJson = true
    var response: APIResponse = APIResponse(status: "error", message: "network_err_connection_didnt_start", payload: nil)

    var retreivedImage: UIImage? = nil
    func popErrorUp(on viewController: UIViewController) {
        viewController.present(title: "Error", message: self.response.message ?? "Something Went Wrong", actions: [UIAlertAction(title: "OK", style: .default, handler: nil)])
    }
    convenience init(withTarget target: String) {
        self.init()
        self.target = target
    }

    var uparams: [String] = []
    private func getUParams() -> String {
        var u = ""
        var first = true
        for p in uparams {
            u.append(first ? "\(p)" : "&\(p)")
            if first { first = false }
        }
        return u
    }

    var calledUrl: URL? = nil


    func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }

    func createDataBody(data: Data, boundary: String) -> Data {

        let lineBreak = "\r\n"
        var body = Data()


        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\(lineBreak)")
        body.append("Content-Type: image/jpeg\(lineBreak + lineBreak)")
        body.append(data)
        body.append(lineBreak)
        body.append("--\(boundary)--\(lineBreak)")

        return body
    }


    func start() {

        let url = (BaseRequest.baseUrl + target).toURL!

        urlRequest = URLRequest(url: url)
        if let retreivedImage = retreivedImage {
            urlRequest?.httpMethod = "POST"
            let boundary = generateBoundary()
            urlRequest?.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            urlRequest?.addValue("Client-ID f65203f7020dddc", forHTTPHeaderField: "Authorization")
            let dataBody = createDataBody(data: retreivedImage.jpegData(compressionQuality: 1)!, boundary: boundary)
            urlRequest?.httpBody = dataBody
        }

        calledUrl = url
        print(url.absoluteString)

        URLSession.shared.dataTask(with: urlRequest!, completionHandler: { (data, urlResponse, error) in

            self.rawResponse = data

            // so basically the first one is repeated (it will be done again in the dispatch) and the second could have been
            // moved to 'else' in the dispatch
//            self.response.message = (error == nil) ? nil : String(describing: error!)
            if error != nil {
                DispatchQueue.main.async {
                    self.onFail?();
                }
                return
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + self.delay) {
                if self.processJson {
                    do {
                        self.response = try JSONDecoder().decode(APIResponse.self, from: data ?? Data())
                        if self.response.status == "ok" {
                            self.onSuccess?()
                        } else {
                            self.onFail?()
                        }
                    } catch let error as NSError {
                        print("API JSON Conversion Failed at \(url.absoluteString) with error: " + error.description)
                        self.response.message = "network_err_json_conversation_failed"
                        self.onFail?()
                    }
                } else {
                    self.onSuccess?()
                }
            }
        }).resume()

    }

}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}


extension UIViewController {
    func present(title: String, message: String, actions: [UIAlertAction], alertType: UIAlertController.Style = .alert) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: alertType)
        for action in actions {
            alert.addAction(action)
        }
        self.present(alert, animated: true, completion: nil)
    }
}
