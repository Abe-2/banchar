

import UIKit

var id = "0"
var plate = ""
var car = ""
var img = ""

class LoginClientViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblTerms: UILabel!
    @IBOutlet weak var vwContents: UIView!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtname: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        imgIcon.layer.cornerRadius = 24

        for txt in [txtUsername, txtPassword] {
            txt!.layer.cornerRadius = 16
            txt!.layer.shadowColor = UIColor.black.cgColor
            txt!.layer.shadowRadius = 10
            txt!.layer.shadowOffset = CGSize(width: 0, height: 5)
            txt!.layer.shadowOpacity = 0.2
        }

        lblTerms.attributedText = attributedText(withString: "By creating an account, you agree to our\nTerms of Service and Privacy Policy", boldStrings: "Terms of Service", "Privacy Policy", font: lblTerms.font)

        KeyboardAvoiding.avoidingView = vwContents
    }


    func attributedText(withString string: String, boldStrings: String..., font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
            attributes: [NSAttributedString.Key.font: font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        for s in boldStrings {
            let range = (string as NSString).range(of: s)
            attributedString.addAttributes(boldFontAttribute, range: range)
        }

        return attributedString
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func btnLoginAction(_ sender: Any) {
        indicator.startAnimating()
        let username = txtUsername.text ?? ""
        let password = txtPassword.text ?? ""

        if username == "" || password == "" {
            let alert = UIAlertController(title: "Error", message: "Please fill all the textfields.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            indicator.stopAnimating()
            return
        }

        let request = APIRequest(withTarget: Target.login(phone: username, password: password))
        request.onSuccess = {
            id = request.response.payload?.id ?? "0"
            carType = request.response.payload?.car_type ?? ""
            plate = request.response.payload?.plate_num ?? ""
            img = request.response.payload?.img ?? ""
            let vc = VCs.newClientHome()
            self.present(vc, animated: true, completion: nil)
            self.indicator.stopAnimating()
        }
        request.onFail = {
            let alert = UIAlertController(title: "Error", message: "Something went wrong.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        request.start()
    }
}

