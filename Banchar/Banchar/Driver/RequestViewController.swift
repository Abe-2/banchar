//
//  RequestViewController.swift
//  Banchar
//
//  Created by Forat Bahrani on 12/7/19.
//  Copyright © 2019 Forat Bahrani. All rights reserved.
//

import UIKit

class RequestViewController: UIViewController {

    @IBOutlet weak var btnEnd: DesignableButton!
    @IBOutlet weak var lblCar: UILabel!
    @IBOutlet weak var lblPlate: UILabel!
    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var ind: UIActivityIndicatorView!
    
    var req : Request? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        (self.children[0] as! RequestMapViewController).req = req
        (self.children[0] as! RequestMapViewController).setup()
        lblCar.text = "Car: \(req!.car_type)"
        lblPlate.text = "Plate: \(req!.plate_num)"
        lblDescription.text = "Description: \(req!.description)"
       
        getData(from: self.req!.img.toURL!) { data, response, error in
            print(1)
            guard let data = data, error == nil else { return }
            print(self.req!.img.toURL!.absoluteString)
            print(data.count)
            print(2)
            DispatchQueue.main.async() {
                self.ivImage.image = UIImage(data: data)
                print(3)
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    

    @IBAction func acceptActi(_ sender: Any) {
        if ind.isAnimating { return  }
        ind.startAnimating()
        let request = APIRequest()
        request.target = Target.acceptsRequests(request: req!.id, id: id)
        request.onSuccess = {
            self.ind.stopAnimating()
            self.btnAccept.isEnabled = false
            self.btnCancel.isEnabled = false
            self.btnAccept.alpha = 0.5
            self.btnCancel.alpha = 0.5
            self.btnEnd.isHidden = false
        }
        request.onFail = {
            self.ind.stopAnimating()
            request.popErrorUp(on: self)
        }
        request.start()
    }
    @IBAction func decAct(_ sender: Any) {
        if ind.isAnimating { return  }
        ind.startAnimating()
        let request = APIRequest()
        request.target = Target.decline(req: req?.id ?? "0")
        request.onSuccess = {
            self.ind.stopAnimating()
            pauseCheckingRequest = false
            self.dismiss(animated: true, completion: nil)
        }
        request.onFail = {
            self.ind.stopAnimating()
            request.popErrorUp(on: self)
        }
        request.start()
    }
  
    @IBAction func endService(_ sender: Any) {
        if ind.isAnimating { return  }
        ind.startAnimating()
        let request = APIRequest()
        request.target = Target.endRide(req: req?.id ?? "0")
        request.onSuccess = {
            self.ind.stopAnimating()
            pauseCheckingRequest = false
            self.dismiss(animated: true, completion: nil)
        }
        request.onFail = {
            self.ind.stopAnimating()
            pauseCheckingRequest = false
            self.dismiss(animated: true, completion: nil)
        }
        request.start()
    }
    
    

}
