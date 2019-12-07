//
//  HistoryViewController.swift
//  Banchar
//
//  Created by Forat Bahrani on 12/7/19.
//  Copyright © 2019 Forat Bahrani. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let req = requests[indexPath.row]
        let lblStatus = cell.contentView.viewWithTag(1) as! UILabel
        switch req.status {
        case "0":
            lblStatus.text = "Pending"
            break
        case "1":
            lblStatus.text = "Accepted"
            break
        case "2":
            lblStatus.text = "Completed"
            break
        case "3":
            lblStatus.text = "Canceled"
            break
        case "4":
            lblStatus.text = "Declined"
            break
        default:
            break
        }
        let lblDate = cell.contentView.viewWithTag(2) as! UILabel
        let lblDesc = cell.contentView.viewWithTag(3) as! UILabel
        lblDesc.text = req.description
        lblDate.text = req.date ?? ""
        return cell
    }


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ind: UIActivityIndicatorView!
    var requests: [Request] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ind.startAnimating()
        let req = APIRequest()
        req.target = Target.history()
        req.onSuccess = {
            self.requests = req.response.payload?.requests ?? []
            self.tableView.reloadData()
            self.ind.stopAnimating()
        }
        req.onFail = {
            req.popErrorUp(on: self)
            self.ind.stopAnimating()
        }
        req.start()
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
