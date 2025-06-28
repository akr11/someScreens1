//
//  SignUpViewController.swift
//  someScreens1
//
//  Created by andriy kruglyanko on 23.04.2025.
//

import UIKit
import CoreData
import PhotosUI
import SwiftyBeaver
import PhoneNumberKit
import Network


class SignUpViewController: BaseViewController, NSFetchedResultsControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {


    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: PhoneNumberTextField!
    @IBOutlet weak var curTableView: UITableView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var choosePhotoButton: UIButton!
    @IBOutlet weak var progresView: UIProgressView!
    @IBOutlet weak var phoneToastLabel: UILabel!
    @IBOutlet weak var photoToastLabel: UILabel!
    
    @IBOutlet weak var nameToastLabel: UILabel!
    @IBOutlet weak var emailToastLabel: UILabel!
    @IBOutlet weak var rootviewForPhotoButtons: UIView!
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    @IBOutlet weak var heightTableConstraint: NSLayoutConstraint!
    var imagePickerController = UIImagePickerController()
    var capturedImages = [UIImage]()
    @IBOutlet weak var imageView: UIImageView!
    weak var delegateToPrevious: CameraViewControllerDelegate?

    var options: [Option] = [
            Option(title: "Option 1", isSelected: false),
            Option(title: "Option 2", isSelected: false),
            Option(title: "Option 3", isSelected: false)
        ]
    var selectedPos: Position?
    var text: String = ""
    var error: Error?

    override func viewDidLoad() {
        super.viewDidLoad()
        nameTF.delegate = self
        nameTF.tag = 0
        nameTF.returnKeyType = .next

        emailTF.delegate = self
        emailTF.tag = 1
        emailTF.returnKeyType = .next

        phoneTF.delegate = self
        phoneTF.tag = 2
        phoneTF.returnKeyType = .done
//
//                textField4.delegate = self
//                textField4.tag = 3 // Last one
//                textField4.returnKeyType = .done
        if UIScreen.main.traitCollection.userInterfaceStyle == .dark {
            choosePhotoButton.setTitleColor(UIColor.label, for: .normal)
            phoneToastLabel.textColor = UIColor.label
        } else {
            choosePhotoButton.setTitleColor(UIColor.gray, for: .normal)
            phoneToastLabel.textColor = UIColor.gray
        }
        DispatchQueue.main.async {
            self.setTextFieldToNoErrorState(self.nameTF, self.nameToastLabel, "")
            self.setTextFieldToNoErrorState(self.emailTF, self.emailToastLabel, "")
            self.setTextFieldToNoErrorState(self.phoneTF, self.phoneToastLabel, "")
            self.setForPhotoToNoErrorState(self.photoToastLabel, "")
            self.nameTF.placeholder = "Your name"
            self.emailTF.placeholder = "Email"
            self.phoneTF.placeholder = "Phone"
        }

        phoneToastLabel.isHidden = true
        emailToastLabel.isHidden = true
        nameToastLabel.isHidden = true
        photoToastLabel.isHidden = true
        choosePhotoButton.setTitleColor(UIColor.label, for: .normal)
//        curTableView.dataSource = self
//        curTableView.delegate = self
        curTableView.register(RadioButtonCell.self, forCellReuseIdentifier: "RadioButtonCell")
        initializeFetchedResultsController()
        imagePickerController.modalPresentationStyle = .currentContext
        imagePickerController.delegate = self
        ApiManager.shared().getPositions(completion: {  (data, response, error) in
            SwiftyBeaver.debug("data = \(String(describing: data))")
            SwiftyBeaver.debug("response = \(String(describing: response))")
            SwiftyBeaver.debug("error = \(String(describing: error))")
            guard
                let httpURLResponse = response as? HTTPURLResponse,
                httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType,  //mimeType.hasPrefix("application/json"),
                let data = data, error == nil

            else {
                if (error?.localizedDescription) != nil {
                    SwiftyBeaver.debug((error?.localizedDescription)! as String)
                }
                return
            }


            do {
                let json =
                try JSONSerialization.jsonObject(
                    with: data,
                    options: .allowFragments
                ) as! NSDictionary

                if let arU = (json["positions"] as? [Dictionary<String, AnyObject>]),
                   arU.count > 0 {
                    do {

                        SwiftyBeaver.debug("arU = \(String(describing: arU))")
                        try ApiManager.shared().treatmentPositions(
                            positionsAr: arU
                        )
                    } catch {
                        SwiftyBeaver.debug(error)
                    }
                } else {
                }
            } catch let error as NSError {
                SwiftyBeaver.debug(error.localizedDescription)
            }

        })
        setupHideKeyboardOnTap()
        if let n = fetchedResultsController.sections?[0].numberOfObjects,
           n > 0 {
            selectedPos = (self.fetchedResultsController.object(at: self.curTableView.indexPathForSelectedRow ?? IndexPath(row: 0, section: 0)) as? Position)
        }
//        selectedPos = (self.fetchedResultsController.object(at: self.curTableView.indexPathForSelectedRow ?? IndexPath(row: 0, section: 0)) as? Position)
        //selectedPos = (self.fetchedResultsController.object(at: self.curTableView.indexPathForSelectedRow ?? IndexPath(row: 0, section: 0)) as? Position)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SwiftyBeaver.debug("SignUpViewController viewWillAppear ")
        SwiftyBeaver.debug(" self.navigationController.viewControllers = \(self.navigationController?.viewControllers ?? [])")
        SwiftyBeaver.debug(" self.presentationController = \(String(describing: self.presentationController))")
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        if let im = capturedImages.first {
            DispatchQueue.main.async {
                self.imageView.image = im
                self.imageView.setNeedsDisplay()
                self.setForPhotoToNoErrorState(self.photoToastLabel, "")
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        removeNetworkObserver()
    }

    private func setupHideKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // Allow taps to go through to other views (like buttons)
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Network Monitoring
    
//    private func setupNetworkObserver() {
//        networkObserver = NotificationCenter.default.addObserver(
//            forName: NetworkManager.networkStatusChanged,
//            object: nil,
//            queue: .main
//        ) { [weak self] notification in
//            self?.handleNetworkStatusChange(notification: notification)
//        }
//    }
//    
//    private func removeNetworkObserver() {
//        if let observer = networkObserver {
//            NotificationCenter.default.removeObserver(observer)
//            networkObserver = nil
//        }
//    }
    
    private func handleNetworkStatusChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let isConnected = userInfo["isConnected"] as? Bool,
              let wasConnected = userInfo["wasConnected"] as? Bool else {
            return
        }
        
        SwiftyBeaver.info("📱 SignUpViewController: Network status changed: isConnected=\(isConnected), wasConnected=\(wasConnected)")
        
        if !wasConnected && isConnected {
            // Network became available
            SwiftyBeaver.info("✅ Network became available")
        } else if wasConnected && !isConnected {
            // Network became unavailable
            SwiftyBeaver.warning("❌ Network became unavailable, showing no internet connection screen")
            showNoInternetConnection()
        }
    }
    
//    private func checkNetworkStatus() {
//        SwiftyBeaver.info("🔍 Checking initial network status: \(networkManager.isConnected)")
//        if !networkManager.isConnected {
//            SwiftyBeaver.warning("❌ No internet connection detected, showing no internet connection screen")
//            showNoInternetConnection()
//        }
//    }
    
    private func showNoInternetConnection() {
        // Check if we're not already showing the no internet connection screen
        if !(navigationController?.viewControllers.last is NoInternetConnectionViewController) {
            SwiftyBeaver.info("🔄 Performing segue to noInternetConnection")
            performSegue(withIdentifier: "noInternetConnection", sender: self)
        } else {
            SwiftyBeaver.info("ℹ️ NoInternetConnectionViewController is already showing")
        }
    }

    func goToSuccess(text: String) {
        DispatchQueue.main.async {
            self.text = text
            self.performSegue(withIdentifier: "successReg", sender: self)
        }
    }

    func goToFailure(text: String, error: Error? = nil) {
        self.text = text
        self.error = error
        performSegue(withIdentifier: "failReg", sender: self)
    }

    @IBAction func signUpClicked(_ sender: Any) {
        // Check network status before making API call
        guard checkNetworkBeforeAPICall() else { return }
        DispatchQueue.main.async {
            self.setTextFieldToNoErrorState(self.nameTF, self.nameToastLabel, "")
            self.setTextFieldToNoErrorState(self.emailTF, self.emailToastLabel, "")
            self.setTextFieldToNoErrorState(self.phoneTF, self.phoneToastLabel, "")
            self.setForPhotoToNoErrorState(self.photoToastLabel, "")
            self.nameTF.placeholder = "Your name"
            self.emailTF.placeholder = "Email"
            self.phoneTF.placeholder = "Phone"
        }

        phoneToastLabel.isHidden = true
        emailToastLabel.isHidden = true
        nameToastLabel.isHidden = true
        photoToastLabel.isHidden = true

        var token = ""
//        DispatchQueue.main.async {
//            self.setTextFieldToNoErrorState(self.nameTF, self.nameToastLabel, "")
//            self.setTextFieldToNoErrorState(self.emailTF, self.emailToastLabel, "")
//            self.setTextFieldToNoErrorState(self.phoneTF, self.phoneToastLabel, "")
//            self.setForPhotoToNoErrorState(self.photoToastLabel, "")
//        }
        //        guard let token1 = UserDefaults.standard.string(forKey: "token") else {
        //            SwiftyBeaver.debug("No credentials yet")
        ApiManager.shared().getToken(completion: {  (data, response, error) in
            SwiftyBeaver.debug("data = \(String(describing: data))")
            SwiftyBeaver.debug("response = \(String(describing: response))")
            SwiftyBeaver.debug("error = \(String(describing: error))")
            guard
                let httpURLResponse = response as? HTTPURLResponse,
                httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType,  //mimeType.hasPrefix("application/json"),
                let data = data, error == nil

            else {
                if (error?.localizedDescription) != nil {
                    SwiftyBeaver.debug((error?.localizedDescription)! as String)
                }
                return
            }


            do {
                let json =
                try JSONSerialization.jsonObject(
                    with: data,
                    options: .allowFragments
                ) as! NSDictionary

                SwiftyBeaver.debug(json)
                if let success = json["success"] as? Int,
                   success == 1 {
                    SwiftyBeaver.debug(success)
                    if let token2 = json["token"] as? String {
                        UserDefaults.standard.set(token2, forKey: "token")
                        UserDefaults.standard.synchronize()
                        token = token2
                        var pos: Int64 = 0
                        if let pos1 = self.selectedPos {
                            pos  = pos1.id
                        }
                        var curIm = UIImage()
                        if let im = self.capturedImages.first {
                            curIm = im
                        }
                        SwiftyBeaver.debug("Registration token: \(token)")
                        ApiManager.sharedInstance.registerUser(name: self.nameTF.text ?? "nameTF",
                                                               email: self.emailTF.text ?? "abc@gmail.com",
                                                               phone: self.phoneTF.text ?? "+380989456123",
                                                               positionId: Int(pos),
                                                               photo: curIm,
                                                               token: token,
                                                               completion: { result in
                            SwiftyBeaver.debug("Registration result: \(result)")
                            switch result {
                            case .success(let data):
                                do {
                                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                                       let message = json["message"] as? String {
                                        SwiftyBeaver.debug("Success: \(message)")
                                        self.goToSuccess(text: message)
                                    }
                                } catch {
                                    SwiftyBeaver.debug("Error parsing response: \(error)")
                                }
                            case .failure(let error):
                                SwiftyBeaver.debug("Registration failed: \(error)")
                                var mes: String = ""
                                if let message = (error as? NetworkError)?.message as? String {
                                    mes = message
                                    DispatchQueue.main.async {
                                        self.goToFailure(text: message, error: error)
                                    }
                                    SwiftyBeaver.debug(mes)
                                }
                                switch error {
                                case ValidationError.invalidName:
                                    SwiftyBeaver.error("❌ Invalid name")
                                    //>=2 <=60
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        mes = "Name should be between 2 and 60 characters"
                                        self.setTextFieldToErrorState(self.nameTF, self.nameToastLabel, mes)
                                        //.makeToast("Name should be between 2 and 60 characters")
                                    }

                                case ValidationError.invalidEmail:
                                    SwiftyBeaver.error("❌ Invalid invalidEmail")
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                                            mes = "Invalid email format"
                                                                            self.setTextFieldToErrorState(self.emailTF, self.emailToastLabel, mes)
                                                                            //.makeToast("Name should be between 2 and 60 characters")
                                                                        }

                                case ValidationError.invalidPhone:
                                    SwiftyBeaver.error("❌ Invalid invalidPhone")
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        mes = "Invalid phone format"
                                        self.setTextFieldToErrorState(self.phoneTF, self.phoneToastLabel, mes)
                                        //.makeToast("Name should be between 2 and 60 characters")
                                    }
                                case ValidationError.photoConversionFailed:
                                    SwiftyBeaver.error("❌ Invalid photoConversionFailed")
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        mes = "Photo is required"
                                        self.setPhotoToErrorState(self.photoToastLabel, mes, self.choosePhotoButton)
//                                        self.setTextFieldToErrorState(self.phoneTF, self.phoneToastLabel, mes)
                                        //.makeToast("Name should be between 2 and 60 characters")
                                    }

                                case ValidationError.photoTooLarge:
                                    SwiftyBeaver.error("❌ Photo too large")
                                    DispatchQueue.main.async {
                                        self.goToFailure(text: "Photo is too large. Please select a smaller image (max 5MB)", error: error)
                                    }

                                case ValidationError.photoTooSmall:
                                    SwiftyBeaver.error("❌ Photo too small")
                                    DispatchQueue.main.async {
                                        self.goToFailure(text: "Photo resolution is too small. Please select an image with at least 70x70 pixels", error: error)
                                    }
                                case RegistrationError.emailTaken:
                                    SwiftyBeaver.error("❌ Email is already taken")
                                    DispatchQueue.main.async {
                                        self.goToFailure(text: "This email is already registered. Please use a different email address", error: error)
                                    }
                                case RegistrationError.weakPassword:
                                    SwiftyBeaver.error("❌ Password is too weak")
                                    DispatchQueue.main.async {
                                        self.goToFailure(text: "Password is too weak. Please choose a stronger password", error: error)
                                    }
                                case RegistrationError.unknown(let message):
                                    SwiftyBeaver.error("❌ Unknown error: \(message)")
                                    DispatchQueue.main.async {
                                        self.goToFailure(text: message.isEmpty ? "Unknown registration error occurred" : message, error: error)
                                    }
                                default:
                                    SwiftyBeaver.error("❌ Unhandled error: \(error.localizedDescription)")
                                    DispatchQueue.main.async {
                                        self.goToFailure(text: "An unexpected error occurred. Please try again", error: error)
                                    }
                                }
//                            case NetworkError.serverError(let statusCode, let message): //NetworkError.serverError(let Status, let message) = error {
//                                mes = message
//                                                                DispatchQueue.main.async {
//                                                                    self.goToFailure(text: mes)
//                                                                }
//                                SwiftyBeaver.error("❌ Server error: \(message)")
//                            } catch {
//
//                            }

                            }
                        })
                    }
                } else {
                    SwiftyBeaver.debug(json)
                }
            } catch let error as NSError {
                SwiftyBeaver.debug(error.localizedDescription)
            }

        })
        //            return
        //        }
        //
        //        token = token1

    }

    func setTextFieldToErrorState(_ textField: UITextField, _ label: UILabel, _ text: String) {
        SwiftyBeaver.info("TtextField.layer.borderColor: \(String(describing: textField.layer.borderColor))")
        textField.layer.borderColor = UIColor.red.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 5.0

        SwiftyBeaver.info("UIColor.placeholderText \(String(describing:  UIColor.placeholderText))")
        textField.attributedPlaceholder = NSAttributedString(
            string: "Please enter valid input",
            attributes: [.foregroundColor: UIColor.red]
        )
        label.isHidden = false
        label.textColor = .red
        label.text = text
        
        
        label.sizeToFit()
        label.setNeedsLayout()
        label.layoutIfNeeded()
    }

    func setTextFieldToNoErrorState(_ textField: UITextField, _ label: UILabel, _ text: String) {
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 5.0

        textField.attributedPlaceholder = NSAttributedString(
            string: "Please enter valid input",
            attributes: [.foregroundColor: UIColor.placeholderText]
        )
        label.isHidden = true
        label.textColor = .red
        label.text = text
        label.sizeToFit()
        label.setNeedsLayout()
        label.layoutIfNeeded()
    }

    func setForPhotoToNoErrorState(_ label: UILabel, _ text: String) {
        rootviewForPhotoButtons.layer.borderColor = UIColor.systemGray4.cgColor
        choosePhotoButton.setTitle("Upload yor photo", for: .normal)
        choosePhotoButton.setTitleColor(UIColor.systemGray4, for: .normal)
        SwiftyBeaver.info("String(describing: choosePhotoButton.titleColor(for: .normal) = \(String(describing: choosePhotoButton.titleColor(for: .normal)))")
        label.isHidden = true
        label.textColor = .red
        label.text = text
    }

    func setPhotoToErrorState(_ label: UILabel, _ text: String, _ button: UIButton) {
        rootviewForPhotoButtons.layer.borderColor = UIColor.red.cgColor
        button.setTitle("Upload yor photo", for: .normal)
        DispatchQueue.main.async {
            UIView.transition(with: button, duration: 0.3, options: .transitionCrossDissolve) {
                button.setTitleColor(.red, for: .normal)
            }
            button.setTitleColor(UIColor.red, for: .normal)
            SwiftyBeaver.debug("String(describing: choosePhotoButton.titleColor(for: .normal) = \(String(describing: button.titleColor(for: .normal)))")
            button.titleLabel?.setNeedsDisplay()
            button.titleLabel?.setNeedsLayout()
            SwiftyBeaver.debug("String(describing: choosePhotoButton.titleColor(for: .normal) = \(String(describing: button.titleColor(for: .normal)))")
        }

        label.isHidden = false
        label.textColor = .red
        label.text = text
    }


    func validatePhoneNumber() {
            guard let rawNumber = phoneTF.text, !rawNumber.isEmpty else {
                phoneToastLabel.text = "Please enter a phone number."
                phoneToastLabel.textColor = .orange
                return
            }

            do {
                // Attempt to parse the number. PhoneNumberKit will automatically
                // try to guess the region if not specified, based on the device's locale.
                let phoneNumberUtility = PhoneNumberUtility()
                let phoneNumber = try phoneNumberUtility.parse(rawNumber)
                SwiftyBeaver.debug(phoneNumber)
                // At this point, the number is considered valid by PhoneNumberKit's parsing logic.
                // You can further refine validation based on type (mobile, fixedLine, etc.)
                var validationStatus = "Valid Number 🎉"
                var details = ""
                setTextFieldToNoErrorState(phoneTF, phoneToastLabel, "")
                details += "Country Code: +\(phoneNumber.countryCode)\n"
                details += "National Number: \(phoneNumber.nationalNumber)\n"
                details += "Number Type: \(phoneNumber.type)\n"

                // Example of further validation: Check if it's a mobile number
                if phoneNumber.type == .mobile {
                    details += "This is a mobile number."
                } else {
                    details += "This is NOT a mobile number (it's \(phoneNumber.type))."
                }

                phoneToastLabel.text = "\(validationStatus)\n\(details)"
                phoneToastLabel.textColor = .systemGreen
                SwiftyBeaver.debug("\(validationStatus)\n\(details)")
            } catch {
                // If parsing fails, it's considered an invalid number by PhoneNumberKit
                phoneToastLabel.text = "Invalid Phone Number ❌\nError: \(error.localizedDescription)"
                phoneToastLabel.textColor = .systemRed
                SwiftyBeaver.debug(error.localizedDescription)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let mes = "Invalid phone format"
                    self.setTextFieldToErrorState(self.phoneTF, self.phoneToastLabel, mes)
                    //.makeToast("Name should be between 2 and 60 characters")
                }
            }
        }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = view.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // No next text field found, dismiss keyboard
            textField.resignFirstResponder()
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 2 {
            validatePhoneNumber()
        }
        self.view.endEditing(true)
    }

    //MARK: - fetched controller

    func initializeFetchedResultsController() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Position")
        let created_atSort = NSSortDescriptor(key: "id", ascending: false)
        request.sortDescriptors = [created_atSort]
        let managedObjectContext =
            CoredataStack.mainContext

        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self


        do {
            try fetchedResultsController.performFetch()
            self.heightTableConstraint.constant = CGFloat((self.fetchedResultsController.fetchedObjects?.count ?? 1) * 44)
            self.curTableView.setNeedsDisplay()
            self.view.layoutIfNeeded()
            curTableView.reloadData()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        SwiftyBeaver.debug("position didChange sectionInfo type = \(type)")
        self.curTableView.reloadData()
        switch type {
        case .insert:
            self.curTableView?.performBatchUpdates({
                curTableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
                curTableView.reloadData()
            }, completion: nil)

        case .delete:
            self.curTableView?.performBatchUpdates({
                curTableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
                curTableView.reloadData()
            }, completion: nil)

        case .move:
            if self.curTableView.numberOfSections > 0 {
                self.curTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
            break
        case .update:
            break
        @unknown default:
            break
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        SwiftyBeaver.debug("controllerWillChangeContent")
        DispatchQueue.main.async {
            self.curTableView.reloadData()
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        SwiftyBeaver.debug("post create edit didChange indexPath type = \(type.rawValue)")
        switch type {
        case .insert:
            DispatchQueue.main.async {
                self.curTableView.reloadData()
            }
            break

        case .delete:
            DispatchQueue.main.async {
                self.curTableView.reloadData()
            }
        case .move:
            self.curTableView.reloadData()
            break
        case .update:
            DispatchQueue.main.async {
                self.curTableView.reloadData()
            }
            break
        @unknown default:
            SwiftyBeaver.debug("@unknown default")
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        SwiftyBeaver.debug("controllerDidChangeContent  fetchedResultsController.fetchedObjects?.count =  \(String(describing: fetchedResultsController.fetchedObjects?.count))")

        DispatchQueue.main.async {
            if self.fetchedResultsController.fetchedObjects?.count ?? 0 > 0 {
                // hide mock
    //            noUsersLabel.sendSubviewToBack(<#T##view: UIView##UIView#>)
//                self.heightTableConstraint.constant = CGFloat((self.fetchedResultsController.fetchedObjects?.count ?? 1) * 44)
//                self.curTableView.setNeedsDisplay()
                SwiftyBeaver.debug("sendSubviewToBack")
//                self.noUsersLabel.superview?.sendSubviewToBack(self.noUsersLabel)
//                self.noUsersImageView.superview?.sendSubviewToBack(self.noUsersImageView)
    //            childView.superview?.bringSubviewToFront(childView)
            } else {
                SwiftyBeaver.debug("bringSubviewToFront")
//                self.noUsersLabel.superview?.bringSubviewToFront(self.noUsersLabel)
//                self.noUsersImageView.superview?.bringSubviewToFront(self.noUsersImageView)
            }
            self.curTableView.reloadData()
            self.curTableView.layoutIfNeeded()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func showFromCamera() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)

        if authStatus == AVAuthorizationStatus.denied {
            // The system denied access to the camera. Alert the user.

            /*
             The user previously denied access to the camera. Tell the user this
             app requires camera access.
            */
            let alert = UIAlertController(title: "Unable to access the Camera",
                                          message: "To turn on camera access, choose Settings > Privacy > Camera and turn on Camera access for this app.",
                                          preferredStyle: UIAlertController.Style.alert)

            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okAction)

            let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { _ in
                // Take the user to the Settings app to change permissions.
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        // The resource finished opening.
                    })
                }
            })
            alert.addAction(settingsAction)

            present(alert, animated: true, completion: nil)
        } else if authStatus == AVAuthorizationStatus.notDetermined {
            /*
             The user never granted or denied permission for media capture with
             the camera. Ask for permission.

             Note: The app must provide a `Privacy - Camera Usage Description`
             key in the Info.plist with a message telling the user why the app
             is requesting access to the device's camera. See this app's
             Info.plist for such an example usage description.
            */
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                if granted {
                    DispatchQueue.main.async {
                        SwiftyBeaver.debug("CameraViewController didFinishProcessingPhoto self.navigationController.viewControllers = \(self.navigationController?.viewControllers ?? [])")
                        SwiftyBeaver.debug(" self.presentationController = \(String(describing: self.presentationController))")
                        let vc = CameraViewController()
                        vc.delegateToPrevious = self
                        self.navigationController?.pushViewController(vc, animated: true)
//                        self.present(CameraViewController(), animated: true)
//                        (self.navigationController?.viewControllers[0] as? UITabBarController)?.navigationController?.pushViewController(CameraViewController(), animated: true)
//                        self.navigationController?.pushViewController(CameraViewController(), animated: true)
                        //self.showImagePicker(sourceType: UIImagePickerController.SourceType.camera, button: self.choosePhotoButton)
                    }
                }
            })
        } else {
            /*
             The user granted permission to access the camera. Present the
             picker for capture.

             Set the image picker `sourceType` property to
             `UIImagePickerController.SourceType.camera` to configure the picker
             for media capture instead of browsing saved media.
            */
            SwiftyBeaver.debug(" self.navigationController.viewControllers = \(self.navigationController?.viewControllers ?? [])")
            SwiftyBeaver.debug(" self.presentationController = \(String(describing: self.presentationController))")
//            self.present(CameraViewController(), animated: true)
            let vc = CameraViewController()
            vc.delegateToPrevious = self
            self.navigationController?.pushViewController(vc, animated: true)
            //showImagePicker(sourceType: UIImagePickerController.SourceType.camera, button: choosePhotoButton)
        }
    }

    func showImagePicker(sourceType: UIImagePickerController.SourceType, button: UIButton) {
        // Stop animating the images in the view.
        if (imageView?.isAnimating)! {
            imageView?.stopAnimating()
        }
        if !capturedImages.isEmpty {
            capturedImages.removeAll()
        }

        imagePickerController.sourceType = sourceType
        imagePickerController.modalPresentationStyle =
            (sourceType == UIImagePickerController.SourceType.camera) ?
                UIModalPresentationStyle.fullScreen : UIModalPresentationStyle.popover

        let presentationController = imagePickerController.popoverPresentationController
        // Display a popover from the UIBarButtonItem as an anchor.
        //presentationController?.barButtonItem = button
        presentationController?.permittedArrowDirections = UIPopoverArrowDirection.any

        if sourceType == UIImagePickerController.SourceType.camera {
            /*
             The user tapped the camera button in the app's interface which
             specifies the device's built-in camera as the source for the image
             picker controller.
            */

            /*
             Hide the default controls.
             This sample provides its own custom controls for still image
             capture in an overlay view.
            */
            imagePickerController.showsCameraControls = false

            /*
             Apply the overlay view. This view contains a toolbar with custom
             controls for capturing still images in various ways.
            */
//            overlayView?.frame = (imagePickerController.cameraOverlayView?.frame)!
//            imagePickerController.cameraOverlayView = view
        }

        /*
         The creation and configuration of the camera or media browser
         interface is now complete.

         Asynchronously present the picker interface using the
         `present(_:animated:completion:)` method.
        */
        present(imagePickerController, animated: true, completion: {
            // The block to execute after the presentation finishes.
        })
    }


    @IBAction func chosePhotoClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Choose how you want to choose a photo",
                                      message: "",
                                      preferredStyle: .actionSheet)


        alert.addAction(UIAlertAction(title: NSLocalizedString("Gallery", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"Gallery\" alert occured.")
            var configuration = PHPickerConfiguration()
            configuration.filter = .images // Only show images
            configuration.selectionLimit = 1 // Allow selecting one image

            // Create and present picker
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            self.present(picker, animated: true)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Camera", comment: "Default action"), style: .default, handler: { _ in
            self.showFromCamera()
        }))
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .cancel,
                                      handler: nil))

        self.present(alert, animated: true, completion: nil)


    }

    func uploadPhoto(image: UIImage, to urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        // Convert UIImage to binary Data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageConversionError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }

        // Create URL and request
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "URLError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData

        // Create and start URLSession task
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "ResponseError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }

            // Check status code
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "ServerError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server returned status code \(httpResponse.statusCode)"])))
                return
            }

            if let data = data {
                completion(.success(data))
            } else {
                completion(.failure(NSError(domain: "DataError", code: 4, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            }
        }

        task.resume()
    }

    // Example Usage:
    func exampleImageUpload() {
        // Get an image
        guard let image = UIImage(named: "example_photo") else { return }

        // API endpoint
        let uploadURL = "https://api.example.com/upload"

        // Upload the image
        uploadPhoto(image: image, to: uploadURL) { result in
            switch result {
            case .success(let responseData):
                if let responseString = String(data: responseData, encoding: .utf8) {
                    SwiftyBeaver.debug("Upload successful! Response: \(responseString)")
                } else {
                    SwiftyBeaver.debug("Upload successful! Received binary response.")
                }
            case .failure(let error):
                SwiftyBeaver.debug("Upload failed: \(error.localizedDescription)")
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "successReg" {
            if let destinationVC = segue.destination as? SuccessRegViewController {
                destinationVC.text = self.text
            }
        }
        if segue.identifier == "failReg" {
            if let destinationVC = segue.destination as? FailRegViewController {
                destinationVC.text = self.text
                destinationVC.error = self.error
            }
        }
    }

    // MARK: - PHPickerViewControllerDelegate

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // Dismiss the picker
            picker.dismiss(animated: true)

            // Get the selected image
            guard let result = results.first else { return }

            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                if let error = error {
                    SwiftyBeaver.debug("Error loading image: \(error.localizedDescription)")
                    return
                }

                // Handle the loaded image on the main thread
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
//                        self?.imageView.image = image
                        self?.capturedImages.removeAll()
                        self?.capturedImages.append(image)
                        SwiftyBeaver.debug("image =  \(image)")
//                        self?.choosePhotoButton.setTitle(<#T##title: String?##String?#>, for: .normal)
//                        self?.choosePhotoButton.layer.setNeedsDisplay()
                        self?.imageView.image = image
                        self?.capturedImages.append(image)
                        self?.setForPhotoToNoErrorState(self?.photoToastLabel ?? UILabel(), "")
                        // Now you can use this image for uploading or processing
                        // For example, you could call the upload function here:
                        // self?.uploadSelectedImage(image)
                    }
                }
            }
        }


}

// MARK: - Image Selection Delegate Implementation
extension SignUpViewController: ImageSelectionDelegate {
    func didSelectImage(_ image: UIImage) {
        SwiftyBeaver.debug(" image= \(String(describing: image))")
        if !capturedImages.isEmpty {
            capturedImages.removeAll()
        }
        self.capturedImages.append(image)
        self.imageView.image = image
        self.setForPhotoToNoErrorState(self.photoToastLabel, "")
    }
}

// MARK: - Image Selection Delegate Implementation
extension SignUpViewController: CameraViewControllerDelegate {
    func didSelectedImage(_ image: UIImage) {
        SwiftyBeaver.debug(" image= \(String(describing: image))")
        if !capturedImages.isEmpty {
            capturedImages.removeAll()
        }
        self.capturedImages.append(image)
        self.imageView.image = image
        self.setForPhotoToNoErrorState(self.photoToastLabel, "")
    }
}

//import UIKit
//import PhoneNumberKit // Don't forget to import it!
//
//class PhoneNumberValidationViewController: UIViewController {
//
//    let phoneNumberKit = PhoneNumberKit() // Instantiate once, it's expensive
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//
//        // Example Text Field (programmatic for simplicity, but works with IBOutlets too)
//        let phoneNumberTextField = UITextField()
//        phoneNumberTextField.placeholder = "Enter phone number"
//        phoneNumberTextField.borderStyle = .roundedRect
//        phoneNumberTextField.keyboardType = .phonePad
//        phoneNumberTextField.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(phoneNumberTextField)
//
//        let validateButton = UIButton(type: .system)
//        validateButton.setTitle("Validate", for: .normal)
//        validateButton.translatesAutoresizingMaskIntoConstraints = false
//        validateButton.addTarget(self, action: #selector(validatePhoneNumber), for: .touchUpInside)
//        view.addSubview(validateButton)
//
//        let resultLabel = UILabel()
//        resultLabel.numberOfLines = 0
//        resultLabel.textAlignment = .center
//        resultLabel.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(resultLabel)
//
//        NSLayoutConstraint.activate([
//            phoneNumberTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            phoneNumberTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
//            phoneNumberTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            phoneNumberTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            phoneNumberTextField.heightAnchor.constraint(equalToConstant: 40),
//
//            validateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            validateButton.topAnchor.constraint(equalTo: phoneNumberTextField.bottomAnchor, constant: 20),
//            validateButton.heightAnchor.constraint(equalToConstant: 40),
//
//            resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            resultLabel.topAnchor.constraint(equalTo: validateButton.bottomAnchor, constant: 20),
//            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
//        ])
//
//        self.phoneNumberTextField = phoneNumberTextField // Store reference for validation
//        self.resultLabel = resultLabel
//    }
//
//    weak var phoneNumberTextField: UITextField!
//    weak var resultLabel: UILabel!
//
//    @objc func validatePhoneNumber() {
//        guard let rawNumber = phoneNumberTextField.text, !rawNumber.isEmpty else {
//            resultLabel.text = "Please enter a phone number."
//            resultLabel.textColor = .orange
//            return
//        }
//
//        do {
//            // Attempt to parse the number. PhoneNumberKit will automatically
//            // try to guess the region if not specified, based on the device's locale.
//            let phoneNumber = try phoneNumberKit.parse(rawNumber)
//
//            // At this point, the number is considered valid by PhoneNumberKit's parsing logic.
//            // You can further refine validation based on type (mobile, fixedLine, etc.)
//            var validationStatus = "Valid Number 🎉"
//            var details = ""
//
//            details += "Country Code: +\(phoneNumber.countryCode)\n"
//            details += "National Number: \(phoneNumber.nationalNumber)\n"
//            details += "Number Type: \(phoneNumber.type)\n"
//
//            // Example of further validation: Check if it's a mobile number
//            if phoneNumber.type == .mobile {
//                details += "This is a mobile number."
//            } else {
//                details += "This is NOT a mobile number (it's \(phoneNumber.type))."
//            }
//
//            resultLabel.text = "\(validationStatus)\n\(details)"
//            resultLabel.textColor = .systemGreen
//
//        } catch {
//            // If parsing fails, it's considered an invalid number by PhoneNumberKit
//            resultLabel.text = "Invalid Phone Number ❌\nError: \(error.localizedDescription)"
//            resultLabel.textColor = .systemRed
//        }
//    }
//
//    // Optional: You can also use PhoneNumberTextField, which formats as you type
//    // and has built-in validation properties.
//    // class MyViewController: UIViewController {
//    //     let phoneNumberTextField = PhoneNumberTextField()
//    //
//    //     override func viewDidLoad() {
//    //         super.viewDidLoad()
//    //         view.addSubview(phoneNumberTextField)
//    //         phoneNumberTextField.withPrefix = true // Adds country code prefix
//    //         phoneNumberTextField.withExamplePlaceholder = true // Shows example number
//    //         // You can then check phoneNumberTextField.isValidNumber
//    //         // or get the parsed number via phoneNumberTextField.phoneNumber
//    //     }
//    // }
//}
