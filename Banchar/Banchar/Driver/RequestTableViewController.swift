
import UIKit
import GoogleMaps
var carType: String = "3"

class RequestTableViewController: UITableViewController {

    var indicator = UIActivityIndicatorView()

    var requests: [ClientRequest] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }

    func refresh() {
        activityIndicator()
        let request = APIRequest()
        request.target = Target.getRequests(type: "\(carType)")
        request.onSuccess = {
            self.indicator.stopAnimating()
            do {
                self.requests = try JSONDecoder().decode([ClientRequest].self, from: request.rawResponse!)
            } catch {
                request.onFail?()
            }
        }
        request.onFail = {
            self.indicator.stopAnimating()
            let alert = UIAlertController(title: "Error", message: "Something went wrong.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        request.start()
    }

    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.color = .red
        indicator.center = self.view.center
        self.view.addSubview(indicator)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return requests.count
    }

    @IBAction func refresh(_ sender: Any) {
        refresh()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let req = requests[indexPath.row]
        let button = (cell.contentView.viewWithTag(3) as! UIButton)
        let ind = (cell.contentView.viewWithTag(4) as! UIActivityIndicatorView)
        (cell.contentView.viewWithTag(1) as! UILabel).text = "R#" + req.id
        (cell.contentView.viewWithTag(2) as! UILabel).text = req.fare + " KD"
        button.tap { (_) in
            ind.startAnimating()
            let request = APIRequest()
            request.target = Target.acceptsRequests(request: req.id, id: id)
            request.onSuccess = {
                ind.stopAnimating()
                let str = String(data: request.rawResponse!, encoding: .utf8)!
                if str == "accepted request" {
                    let vc = VCs.driverMap()
                    vc.pick = CLLocationCoordinate2D(latitude: Double(req.pickup_x)!, longitude: Double(req.pickup_y)!)
                    vc.dest = CLLocationCoordinate2D(latitude: Double(req.dest_x)!, longitude: Double(req.dest_y)!)
                    vc.req = req.id
                    self.present(vc, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Error", message: str, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            request.onFail = {
                ind.stopAnimating()
                let alert = UIAlertController(title: "Error", message: "Something Went Wrong", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
            request.start()
        }
        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
