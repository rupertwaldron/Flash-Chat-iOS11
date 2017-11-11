import UIKit
import Firebase

import SVProgressHUD

class RegisterViewController: UIViewController {
    //Pre-linked IBOutlets

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func registerPressed(_ sender: AnyObject) {
        SVProgressHUD.show()
        Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in // this is a closure "in"
            if error != nil {
                print(error!)
            } else {
                print("Registration Sucessfull!")
                SVProgressHUD.dismiss()
                // need self. as in a closure
                self.performSegue(withIdentifier: "goToChat", sender: self)
            }
        }
    }
}
