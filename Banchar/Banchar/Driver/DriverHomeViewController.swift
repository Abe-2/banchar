//
//  DriverHomeViewController.swift
//  Banchar
//
//  Created by Forat Bahrani on 12/7/19.
//  Copyright © 2019 Forat Bahrani. All rights reserved.
//

import UIKit
import Cosmos

var pauseCheckingRequest = false

class DriverHomeViewController: UIViewController {
    
    var currDriverRating = 0.0

    @IBOutlet weak var starView: CosmosView!
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (_) in
            if pauseCheckingRequest { return }
            let request = APIRequest()
            request.target = Target.checkRequest()
            request.onSuccess = {
                guard let status = request.response.payload?.request?.status else { return }
                if status == "0" || status == "4" {
                    // TODO: show request
                    pauseCheckingRequest = true
                    let vc = VCs.req()
                    vc.req = request.response.payload?.request
                    self.present(vc, animated: true, completion: nil)
                }
            }
            request.start()
        })
        
        self.starView.rating = self.currDriverRating
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let request = APIRequest()
        request.target = Target.getRating(driver: id)
        request.onSuccess = {
            self.currDriverRating = Double(Int(request.response.payload!.rating!)!)
            self.starView.rating = self.currDriverRating
        }
        request.start()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
