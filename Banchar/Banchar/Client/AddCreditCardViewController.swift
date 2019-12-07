
import UIKit
import CoreData


class AddCreditCardViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var ccNumber1: UITextField!
    @IBOutlet weak var ccNumber2: UITextField!
    @IBOutlet weak var ccNumber3: UITextField!
    @IBOutlet weak var ccNumber4: UITextField!

    @IBOutlet weak var ccExpiryMonth: UITextField!
    @IBOutlet weak var ccExpiryYear: UITextField!

    @IBOutlet weak var ccPin: UITextField!
    @IBOutlet weak var ccHolderName: UITextField!

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    
    var creditCard : NSManagedObject? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.tap { (_) in
            self.view.endEditing(true)
        }
        
        if creditCard == nil {
            return
        }
        
//        guard let creditCard = creditCard else {
//            return
//        }
        let card = creditCard as! CreditCard
        let number1 = card.number![0..<4]
        let number2 = card.number![4..<8]
        let number3 = card.number![8..<12]
        let number4 = card.number![12..<16]
        let expiryMonth = card.expiryMonth!
        let expiryYear = card.expiryYear!
        let pin = card.pin!
        let holderName = card.holderName!
        
        ccNumber1.text = number1
        ccNumber2.text = number2
        ccNumber3.text = number3
        ccNumber4.text = number4
        ccExpiryMonth.text = expiryMonth
        ccExpiryYear.text = expiryYear
        ccPin.text = pin
        ccHolderName.text = holderName
        
        addButton.setTitle("Edit Card", for: .normal)
        removeButton.isHidden = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        validate()
    }


    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.validate()
        }
        if let text = textField.text as NSString? {
            let txtAfterUpdate = text.replacingCharacters(in: range, with: string)
            switch textField {
            case ccNumber1:
                if txtAfterUpdate.count == 4 {
                    DispatchQueue.main.async {
                        self.ccNumber2.becomeFirstResponder()
                    }
                }
                if txtAfterUpdate.count > 4 { return false }
                break
            case ccNumber2:
                if txtAfterUpdate.count == 4 {
                    DispatchQueue.main.async {
                        self.ccNumber3.becomeFirstResponder()
                    }
                }
                if txtAfterUpdate.count > 4 { return false }
                break
            case ccNumber3:
                if txtAfterUpdate.count == 4 {
                    DispatchQueue.main.async {
                        self.ccNumber4.becomeFirstResponder()
                    }
                }
                if txtAfterUpdate.count > 4 { return false }
                break
            case ccNumber4:
                if txtAfterUpdate.count == 4 {
                    DispatchQueue.main.async {
                        self.ccExpiryMonth.becomeFirstResponder()
                    }
                }
                if txtAfterUpdate.count > 4 { return false }
                break
            case ccExpiryMonth:
                if txtAfterUpdate.count == 2 {
                    DispatchQueue.main.async {
                        self.ccExpiryYear.becomeFirstResponder()
                    }
                }
                if txtAfterUpdate.count > 2 { return false }
                break
            case ccExpiryYear:
                if txtAfterUpdate.count == 2 {
                    DispatchQueue.main.async {
                        self.ccPin.becomeFirstResponder()
                    }
                }
                if txtAfterUpdate.count > 2 { return false }
                break
            case ccPin:
                if txtAfterUpdate.count == 3 {
                    DispatchQueue.main.async {
                        self.ccHolderName.becomeFirstResponder()
                    }
                }
                if txtAfterUpdate.count > 3 { return false }
                break
            default:
                return true
            }
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        validate()
        textField.resignFirstResponder()
        return true
    }

    func validate() {
        var isValid = true

        for txt in [ccNumber1, ccNumber2, ccNumber3, ccNumber4] {
            if (txt?.text?.count ?? 0) != 4 {
                isValid = false
            }
        }

        for txt in [ccExpiryMonth, ccExpiryYear] {
            if (txt?.text?.count ?? 0) != 2 {
                isValid = false
            }
        }

        for txt in [ccPin] {
            if (txt?.text?.count ?? 0) != 3 {
                isValid = false
            }
        }

        for txt in [ccHolderName] {
            if (txt?.text?.count ?? 0) < 4 {
                isValid = false
            }
        }

        addButton.isEnabled = isValid
        addButton.alpha = isValid ? 1 : 0.4
    }

    @IBAction func btnAddCardAction(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        if let cc = creditCard as? CreditCard {
            cc.number = ccNumber1.text! + ccNumber2.text! + ccNumber3.text! + ccNumber4.text!
            cc.expiryMonth = ccExpiryMonth.text!
            cc.expiryYear = ccExpiryYear.text!
            cc.pin = ccPin.text!
            cc.holderName = ccHolderName.text!
            do {
                try managedContext.save()
                self.dismiss(animated: true, completion: nil)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        } else {
            let entity = NSEntityDescription.entity(forEntityName: "CreditCard", in: managedContext)!
            let card = NSManagedObject(entity: entity, insertInto: managedContext)

            let number = ccNumber1.text! + ccNumber2.text! + ccNumber3.text! + ccNumber4.text!
            card.setValue(number, forKeyPath: "number")
            card.setValue(ccExpiryMonth.text!, forKey: "expiryMonth")
            card.setValue(ccExpiryYear.text!, forKey: "expiryYear")
            card.setValue(ccPin.text!, forKey: "pin")
            card.setValue(ccHolderName.text!, forKey: "holderName")

            do {
                try managedContext.save()
                self.dismiss(animated: true, completion: nil)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        notify(name: .cardsChanged)
    }
    
    @IBAction func removeButtonAction(_ sender: Any) {
        let alert = UIAlertController(title: "Delete Card", message: "Do you want to delete this card?", preferredStyle: .alert)
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            self.delete()
        }
        let no = UIAlertAction(title: "No", style: .default, handler: nil)
        alert.addAction(no)
        alert.addAction(delete)
        self.present(alert, animated: true, completion: nil)
    }
    
    func delete() {
        guard let creditCard = creditCard else { return }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(creditCard)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.dismiss(animated: true, completion: nil)
        }
        notify(name: .cardsChanged)
    }
}
