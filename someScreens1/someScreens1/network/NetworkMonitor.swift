//
//  NetworkMonitor.swift
//  someScreens1
//
//  Created by andriy kruglyanko on 23.04.2025.
//

import Foundation
import Network
import SwiftyBeaver

//class NetworkMonitor {
//    static let shared = NetworkMonitor()
//    private let monitor: NWPathMonitor
//    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
//    var isConnected: Bool = false
//
//    private init() {
//        monitor = NWPathMonitor()
//        startMonitoring()
//    }
//
//    func startMonitoring() {
//        monitor.pathUpdateHandler = { [weak self] path in
//            self?.isConnected = path.status == .satisfied
//
//            // You can also check connection type
//            if path.usesInterfaceType(.wifi) {
//                SwiftyBeaver.debug("Connected via WiFi")
//            } else if path.usesInterfaceType(.cellular) {
//                SwiftyBeaver.debug("Connected via Cellular")
//            } else if path.usesInterfaceType(.wiredEthernet) {
//                SwiftyBeaver.debug("Connected via Ethernet")
//            } else {
//                SwiftyBeaver.debug("No connection")
//            }
//        }
//        monitor.start(queue: queue)
//    }
//
//    func stopMonitoring() {
//        monitor.cancel()
//    }
//}

class NetworkManager {
    static let shared = NetworkManager()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    // Network status properties
    var isConnected = false
    var connectionType: ConnectionType = .unknown
    var isExpensive = false
    var isConstrained = false

    // Notification for network changes
    static let networkStatusChanged = Notification.Name("NetworkStatusChanged")

    enum ConnectionType {
        case wifi, cellular, ethernet, other, unknown

        var displayName: String {
            switch self {
            case .wifi: return "Wi-Fi"
            case .cellular: return "Cellular"
            case .ethernet: return "Ethernet"
            case .other: return "Other"
            case .unknown: return "Unknown"
            }
        }

        var icon: String {
            switch self {
            case .wifi: return "wifi"
            case .cellular: return "antenna.radiowaves.left.and.right"
            case .ethernet: return "cable.connector"
            case .other: return "network"
            case .unknown: return "questionmark.circle"
            }
        }
    }

    private init() {
        startMonitoring()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.updateNetworkStatus(path: path)
        }
        monitor.start(queue: queue)
    }

    private func updateNetworkStatus(path: NWPath) {
        let wasConnected = isConnected

        isConnected = path.status == .satisfied
        isExpensive = path.isExpensive
        isConstrained = path.isConstrained

        // Determine connection type
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else if path.usesInterfaceType(.other) {
            connectionType = .other
        } else {
            connectionType = .unknown
        }

        // Log network status
        SwiftyBeaver.info("🌐 Network Status Changed:")
        SwiftyBeaver.info("   Connected: \(isConnected)")
        SwiftyBeaver.info("   Type: \(connectionType.displayName)")
        SwiftyBeaver.info("   Expensive: \(isExpensive)")
        SwiftyBeaver.info("   Constrained: \(isConstrained)")
        SwiftyBeaver.info("   Was Connected: \(wasConnected)")

        // Post notification on main queue
        DispatchQueue.main.async {
            let userInfo: [String: Any] = [
                "isConnected": self.isConnected,
                "connectionType": self.connectionType,
                "isExpensive": self.isExpensive,
                "isConstrained": self.isConstrained,
                "wasConnected": wasConnected
            ]

            NotificationCenter.default.post(
                name: Self.networkStatusChanged,
                object: nil,
                userInfo: userInfo
            )
            
            SwiftyBeaver.info("📡 Network status notification posted")
        }
    }

    func stopMonitoring() {
        monitor.cancel()
    }

    deinit {
        stopMonitoring()
    }
}
