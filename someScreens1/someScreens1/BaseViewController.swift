//
//  BaseViewController.swift
//  someScreens1
//
//  Created by andriy kruglyanko on 23.04.2025.
//

import UIKit
import SwiftyBeaver

class BaseViewController: UIViewController {
    
    private let networkService = NetworkService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNetworkMonitoring()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        networkService.startMonitoring(for: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        networkService.stopMonitoring()
    }
    
    // MARK: - Network Monitoring
    
    private func setupNetworkMonitoring() {
        // Override in subclasses if needed
    }
    
    /// Check network before making API calls
    /// - Returns: true if network is available, false otherwise
    func checkNetworkBeforeAPICall() -> Bool {
        return networkService.checkNetworkBeforeAPICall()
    }
    
    /// Override this method to handle network status changes
    /// - Parameter isConnected: Current network connection status
    func networkStatusChanged(isConnected: Bool) {
        // Override in subclasses if needed
        SwiftyBeaver.info("📱 \(type(of: self)): Network status changed to \(isConnected)")
    }
} 