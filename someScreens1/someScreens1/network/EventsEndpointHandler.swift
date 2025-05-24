//
//  EventsEndpointHandler.swift
//  someScreens1
//
//  Created by andriy kruglyanko on 22.04.2025.
//

import Foundation
import SwiftyBeaver

class EventsEndpointHandler {

    private let eventsDbFileName = "events.db"

    func handleEvents(request: URLRequest) -> (data: Data?, error: Error?) {

        if let eventsDbPath = Bundle.main.path(forResource: eventsDbFileName, ofType: "json") {
            do {
                let dbData = try Data(contentsOf: URL(fileURLWithPath: eventsDbPath), options: .mappedIfSafe)
                return (dbData, nil)
            } catch {
                SwiftyBeaver.debug(error)
                return (nil, ApiError.InternalServerError)
            }
        } else {
            SwiftyBeaver.debug("Missing events.db.json file.")
            return (nil, ApiError.InternalServerError)
        }
    }
}
