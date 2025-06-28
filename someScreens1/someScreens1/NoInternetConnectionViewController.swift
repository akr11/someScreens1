//
//  NoInternetConnectionViewController.swift
//  someScreens1
//
//  Created by andriy kruglyanko on 23.04.2025.
//

import UIKit
import SwiftyBeaver

class NoInternetConnectionViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var tryConnectionButton: UIButton!
    
    private let networkManager = NetworkManager.shared
    private var networkObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tryConnectionButton.setTitleColor(UIColor.black, for: .normal)
        setupNetworkObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check if network is already available
        if networkManager.isConnected {
            dismiss(animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeNetworkObserver()
    }
    
    private func setupNetworkObserver() {
        networkObserver = NotificationCenter.default.addObserver(
            forName: NetworkManager.networkStatusChanged,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleNetworkStatusChange(notification: notification)
        }
    }
    
    private func removeNetworkObserver() {
        if let observer = networkObserver {
            NotificationCenter.default.removeObserver(observer)
            networkObserver = nil
        }
    }
    
    private func handleNetworkStatusChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let isConnected = userInfo["isConnected"] as? Bool else {
            return
        }
        
        SwiftyBeaver.info("📱 NoInternetConnectionViewController: Network status changed: isConnected=\(isConnected)")
        
        if isConnected {
            SwiftyBeaver.info("✅ Network became available, dismissing NoInternetConnectionViewController")
            dismiss(animated: true)
        }
    }
    
    @IBAction func tryAgainClicked(_ sender: Any) {
        SwiftyBeaver.info("🔄 Try again button clicked")
        
        // First check with NetworkManager
        if networkManager.isConnected {
            SwiftyBeaver.info("✅ Network is connected via NetworkManager, dismissing")
            DispatchQueue.main.async {
                self.dismiss(animated: true)
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        SwiftyBeaver.info("🔍 Network not connected via NetworkManager, trying URL check")
        // Fallback to URL check
        NoInternetConnectionViewController.isConnectedToInternet() { connected in
            if connected {
                SwiftyBeaver.info("✅ Network is connected via URL check, dismissing")
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                SwiftyBeaver.warning("❌ Network is still not connected")
            }
        }
    }

    static func isConnectedToInternet(completion: @escaping (Bool) -> Void) {
        let url = URL(string: "https://www.apple.com")!
        let task = URLSession.shared.dataTask(with: url) { _, response, error in
            let connected = error == nil && (response as? HTTPURLResponse)?.statusCode == 200
            completion(connected)
        }
        task.resume()
    }

    deinit {
        removeNetworkObserver()
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
