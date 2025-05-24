//
//  NetworkMonitor.swift
//  someScreens1
//
//  Created by andriy kruglyanko on 23.04.2025.
//

import Foundation
import Network
import SwiftyBeaver

class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    var isConnected: Bool = false

    private init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied

            // You can also check connection type
            if path.usesInterfaceType(.wifi) {
                SwiftyBeaver.debug("Connected via WiFi")
            } else if path.usesInterfaceType(.cellular) {
                SwiftyBeaver.debug("Connected via Cellular")
            } else if path.usesInterfaceType(.wiredEthernet) {
                SwiftyBeaver.debug("Connected via Ethernet")
            } else {
                SwiftyBeaver.debug("No connection")
            }
        }
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}
