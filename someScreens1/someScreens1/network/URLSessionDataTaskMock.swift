//
//  URLSessionDataTaskMock.swift
//  someScreens1
//
//  Created by andriy kruglyanko on 22.04.2025.
//

import Foundation

class URLSessionDataTaskMock : URLSessionDataTask, @unchecked Sendable {

    private let taskAction: () -> Void


//    override func `init`(url: URL) {
//
//    }
//
    init(taskAction: @escaping () -> Void) {
        self.taskAction = taskAction
    }

    override func resume() {
        taskAction()
    }

//    override init() {
//            // custom init for mock
//        }

//        override func resume() {
//            // simulate task resuming
//        }

}
