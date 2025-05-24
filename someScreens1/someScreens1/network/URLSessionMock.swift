//
//  URLSessionMock.swift
//  someScreens1
//
//  Created by andriy kruglyanko on 22.04.2025.
//

import Foundation

class URLSessionMock : URLSession, @unchecked Sendable {

    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void

    private let apiEndpoint = "/api/v1/"
    private let eventsEndpoint = "events"

    override func dataTask(
        with url: URL,
        completionHandler: @escaping CompletionHandler) -> URLSessionDataTask
    {
        var error: Error?

        return URLSessionDataTaskMock {
            completionHandler(nil, nil, error)
        }
    }

    override func dataTask(
        with request: URLRequest,
        completionHandler: @escaping CompletionHandler) -> URLSessionDataTask
    {
        let (data, error) = handleRequest(request: request)

        return URLSessionDataTaskMock {
            completionHandler(data, nil, error)
        }
    }

    private func handleRequest(request: URLRequest) -> (data: Data?, error: Error?) {
        var error: Error? = nil

        if let url = request.url {
            switch url.path {
            case apiEndpoint + eventsEndpoint:
                return EventsEndpointHandler().handleEvents(request: request)
            default:
                error = ApiError.BadRequest
            }
        } else {
            error = ApiError.MissingURL
        }

        return (nil, error)
    }
}
