
import UIKit

class DriverRegisterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblTerms: UILabel!
    @IBOutlet weak var vwContents: UIView!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtname: UITextField!
    
    @IBOutlet var btnProfileImg: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        KeyboardAvoiding.avoidingView = vwContents
        self.view.tap { (_) in
            self.view.endEditing(false)
        }
    }

    @IBAction func takePicture() {
        print("pick image")
        // open image picker
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .camera
        self.present(pickerController, animated: true, completion: nil)
    }
    
    
    @IBAction func btnRegisterAction(_ sender: Any) {
        if indicator.isAnimating { return }

        let name = txtname.text ?? ""
        let username = txtUsername.text ?? ""
        let password = txtPassword.text ?? ""
        
        print(name)

        if username == "" || password == "" || name == "" {
            let alert = UIAlertController(title: "Error", message: "Please fill all the textfields.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            indicator.stopAnimating()
            return
        }
        indicator.startAnimating()
        let request = APIRequest(withTarget: Target.driverRegister(name: name, phone: username, password: password))
        request.onSuccess = {
            let str = String(data: request.rawResponse!, encoding: .utf8)!
            if str.contains(username) && str.contains(name) {
                let alert = UIAlertController(title: "Success", message: "Successfully registered.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Error", message: str, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
            self.indicator.stopAnimating()

        }
        request.onFail = {
            self.indicator.stopAnimating()
            request.popErrorUp(on: self)
        }
        request.start()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("done")
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }

        // print out the image size as a test
        btnProfileImg.setImage(image, for: .normal)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled")
        picker.dismiss(animated: true, completion: nil)
    }

}
