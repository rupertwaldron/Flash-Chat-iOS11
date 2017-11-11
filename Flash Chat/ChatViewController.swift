import UIKit
import Firebase
import ChameleonFramework

// need to add protocols need to set ourself as delegate in viewdidload
class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    // Declare instance variables here
    var messageArray : [Message] = [Message]()
    // We've pre-linked the IBOutlets
    // outlet expends height of text field when textfield pressed
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        configureTableView()
        retrieveMessages()
        messageTableView.separatorStyle = .none
    }
    //TODO: Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // set cell as type CustomMessageCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        // change background if you are sending
        if cell.senderUsername.text == Auth.auth().currentUser?.email as String! {
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatOrange()
        } else {
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
        }
        return cell
    }
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    // use number of sections if you want different sections
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
        // calls end editing func below
    }
    
    //TODO: Declare configureTableView here: resize the cells according
    // to content
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }

    //TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            // need to call to update the view
            self.view.layoutIfNeeded()
        }
    }

    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            // need to call to update the view
            self.view.layoutIfNeeded()
        }
    }

    //MARK: - Send & Recieve from Firebase
    @IBAction func sendPressed(_ sender: AnyObject) {
        messageTextfield.endEditing(true)
        //TODO: Send the message to Firebase and save it in our database
        // need to disable the send button whilst still working
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messagesDB = Database.database().reference().child("Messages")
        
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email,
                                 "Messagebody": messageTextfield.text!]
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
            if error != nil {
                print(error!)
            } else {
                print("Message Saved Successfully")
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
                
            }
        }
    }
    
    //TODO: Create the retrieveMessages for new messages:
    func retrieveMessages() {
        let messageDB = Database.database().reference().child("Messages")
        messageDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            let text = snapshotValue["Messagebody"]!
            let sender = snapshotValue["Sender"]!
            let message = Message()
            message.messageBody = text
            message.sender = sender
            self.messageArray.append(message)
            // update table with new message
            self.configureTableView()
            self.messageTableView.reloadData()
        }
    }

    @IBAction func logOutPressed(_ sender: AnyObject) {
        // method throws so need to put in do catch block
        do {
            try Auth.auth().signOut() // signout
            // take user back to root view controller
            //navigationController?.popViewController(animated: true)
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("error, there was a problem signing out")
        }
        //TODO: Log out the user and send them back to WelcomeViewController
  
    }
}
