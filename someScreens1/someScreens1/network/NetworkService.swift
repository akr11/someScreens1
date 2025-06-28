//
//  NetworkService.swift
//  someScreens1
//
//  Created by andriy kruglyanko on 23.04.2025.
//

import UIKit
import SwiftyBeaver

class NetworkService {
    static let shared = NetworkService()
    
    private let networkManager = NetworkManager.shared
    private var networkObserver: NSObjectProtocol?
    private var currentViewController: UIViewController?
    
    private init() {
        setupNetworkObserver()
    }
    
    // MARK: - Public Methods
    
    /// Start monitoring network status for a specific view controller
    /// - Parameter viewController: The view controller to monitor
    func startMonitoring(for viewController: UIViewController) {
        currentViewController = viewController
        SwiftyBeaver.info("📱 NetworkService: Started monitoring for \(type(of: viewController))")
        
        // Check initial network status
        checkNetworkStatus()
    }
    
    /// Stop monitoring network status
    func stopMonitoring() {
        currentViewController = nil
        SwiftyBeaver.info("📱 NetworkService: Stopped monitoring")
    }
    
    /// Check if network is available before making API calls
    /// - Returns: true if network is available, false otherwise
    func checkNetworkBeforeAPICall() -> Bool {
        if !networkManager.isConnected {
            SwiftyBeaver.warning("❌ No internet connection, showing no internet connection screen")
            showNoInternetConnection()
            return false
        }
        return true
    }
    
    // MARK: - Private Methods
    
    private func setupNetworkObserver() {
        networkObserver = NotificationCenter.default.addObserver(
            forName: NetworkManager.networkStatusChanged,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleNetworkStatusChange(notification: notification)
        }
    }
    
    private func handleNetworkStatusChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let isConnected = userInfo["isConnected"] as? Bool,
              let wasConnected = userInfo["wasConnected"] as? Bool else {
            return
        }
        
        SwiftyBeaver.info("📱 NetworkService: Network status changed: isConnected=\(isConnected), wasConnected=\(wasConnected)")
        
        if !wasConnected && isConnected {
            // Network became available
            SwiftyBeaver.info("✅ Network became available")
        } else if wasConnected && !isConnected {
            // Network became unavailable
            SwiftyBeaver.warning("❌ Network became unavailable, showing no internet connection screen")
            showNoInternetConnection()
        }
    }
    
    private func checkNetworkStatus() {
        SwiftyBeaver.info("🔍 NetworkService: Checking initial network status: \(networkManager.isConnected)")
        if !networkManager.isConnected {
            SwiftyBeaver.warning("❌ No internet connection detected, showing no internet connection screen")
            showNoInternetConnection()
        }
    }
    
    private func showNoInternetConnection() {
        guard let viewController = currentViewController else {
            SwiftyBeaver.warning("❌ No current view controller to show no internet connection screen")
            return
        }
        
        // Check if we're not already showing the no internet connection screen
        if !(viewController.navigationController?.viewControllers.last is NoInternetConnectionViewController) {
            SwiftyBeaver.info("🔄 NetworkService: Performing segue to noInternetConnection from \(type(of: viewController))")
            viewController.performSegue(withIdentifier: "noInternetConnection", sender: viewController)
        } else {
            SwiftyBeaver.info("ℹ️ NetworkService: NoInternetConnectionViewController is already showing")
        }
    }
    
    deinit {
        if let observer = networkObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
} 