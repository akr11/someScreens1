//
//  FailRegViewController.swift
//  someScreens1
//
//  Created by andriy kruglyanko on 03.06.2025.
//

import UIKit
import SwiftyBeaver

class FailRegViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    var text: String = ""
    var error: Error?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Display error message
        displayErrorMessage()
    }
    
    private func displayErrorMessage() {
        var displayText = text
        
        // If we have a specific error, provide more detailed information
        if let error = error {
            displayText = getDetailedErrorMessage(for: error)
        }
        
        label.text = displayText
        label.sizeToFit()
        
        SwiftyBeaver.info("📱 FailRegViewController: Displaying error message: \(displayText)")
    }
    
    private func getDetailedErrorMessage(for error: Error) -> String {
        switch error {
        case let validationError as ValidationError:
            return getValidationErrorMessage(validationError)
        case let networkError as NetworkError:
            return getNetworkErrorMessage(networkError)
        case let registrationError as RegistrationError:
            return getRegistrationErrorMessage(registrationError)
        case let apiError as ApiError:
            return apiError.localizedDescription
        default:
            return text.isEmpty ? error.localizedDescription : text
        }
    }
    
    private func getValidationErrorMessage(_ error: ValidationError) -> String {
        switch error {
        case .invalidName:
            return "Name should be between 2 and 60 characters"
        case .invalidEmail:
            return "Invalid email format. Please enter a valid email address"
        case .invalidPhone:
            return "Invalid phone format. Please enter a valid phone number"
        case .photoConversionFailed:
            return "Failed to process photo. Please try again"
        case .photoTooLarge:
            return "Photo is too large. Please select a smaller image (max 5MB)"
        case .photoTooSmall:
            return "Photo resolution is too small. Please select an image with at least 70x70 pixels"
        }
    }
    
    private func getNetworkErrorMessage(_ error: NetworkError) -> String {
        switch error {
        case .invalidResponse:
            return "Invalid response from server. Please check your internet connection and try again"
        case .serverError(let statusCode, let message):
            if !message.isEmpty {
                return "Server error (\(statusCode)): \(message)"
            } else {
                return "Server error (\(statusCode)). Please try again later"
            }
        case .noData:
            return "No data received from server. Please try again"
        }
    }
    
    private func getRegistrationErrorMessage(_ error: RegistrationError) -> String {
        switch error {
        case .invalidName:
            return "Invalid name format"
        case .emailTaken:
            return "This email is already registered. Please use a different email address"
        case .weakPassword:
            return "Password is too weak. Please choose a stronger password"
        case .unknown(let message):
            return message.isEmpty ? "Unknown registration error occurred" : message
        }
    }
    
    @IBAction func buttonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
