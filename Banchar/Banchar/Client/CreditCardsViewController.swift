
import UIKit
import CoreData

var cards: [NSManagedObject] = []

class CreditCardsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var timer: Timer? = nil
    
    var handler: (() -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.contentInset.bottom = 128

        timer = Timer(timeInterval: 0.5, repeats: true, block: { (_) in
            self.refresh()
        })
        doWhen(.cardsChanged) {
            self.refresh()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }

    func refresh() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CreditCard")
        do {
            cards = try managedContext.fetch(fetchRequest)
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let card = cards[indexPath.row] as! CreditCard
        let number1 = card.number![0..<4]
        let number2 = card.number![4..<8]
        let number3 = card.number![8..<12]
        let number4 = card.number![12..<16]
        let expiry = card.expiryMonth! + "/" + card.expiryYear!
        let holderName = card.holderName!

        (cell.contentView.viewWithTag(1) as! UILabel).text = number1
        (cell.contentView.viewWithTag(2) as! UILabel).text = number2
        (cell.contentView.viewWithTag(3) as! UILabel).text = number3
        (cell.contentView.viewWithTag(4) as! UILabel).text = number4
        (cell.contentView.viewWithTag(5) as! UILabel).text = expiry
        (cell.contentView.viewWithTag(7) as! UILabel).text = holderName

        doWhen(.cardsChanged) {
            let number1 = card.number![0..<4]
            let number2 = card.number![4..<8]
            let number3 = card.number![8..<12]
            let number4 = card.number![12..<16]
            let expiry = card.expiryMonth! + "/" + card.expiryYear!
            let holderName = card.holderName!
            (cell.contentView.viewWithTag(1) as! UILabel).text = number1
            (cell.contentView.viewWithTag(2) as! UILabel).text = number2
            (cell.contentView.viewWithTag(3) as! UILabel).text = number3
            (cell.contentView.viewWithTag(4) as! UILabel).text = number4
            (cell.contentView.viewWithTag(5) as! UILabel).text = expiry
            (cell.contentView.viewWithTag(7) as! UILabel).text = holderName
        }

        cell.tap { (_) in
//            if closeit {
//                closeit = false
//                self.dismiss(animated: true, completion: nil)
//                return
//            }
//            let vc = VCs.newCreditCardEdit()
//            vc.creditCard = card
//            self.present(vc, animated: true, completion: nil)
            
            self.dismiss(animated: true, completion: {
                self.handler()
            })
        }

        cell.layoutSubviews()

        return cell
    }




}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: max(0, range.lowerBound))
        let idx2 = index(startIndex, offsetBy: min(self.count, range.upperBound))
        return String(self[idx1..<idx2])
    }
}
