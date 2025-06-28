//
//  ApiManager.swift
//  someScreens1
//
//  Created by andriy kruglyanko on 23.04.2025.
//

import CoreData
import Foundation
import SwiftyBeaver
import UIKit

class ApiManager {
    static let sharedInstance: ApiManager = {
        let instanse = ApiManager()

        return instanse
    }()

    private init() {}

    class func shared() -> ApiManager {
        return sharedInstance
    }

    static let baseURL = Configuration.HOST  //"https://api.unsplash.com/"
    static let perPage = Configuration.perPage  //30

    public func getUsers(
        curPageNumber: Int,
        completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) {
        var urlString = String(
            format: "%@/users?page=%@&per_page=%@",
            ApiManager.baseURL,
            String(describing: curPageNumber),
            String(describing: ApiManager.perPage)
        )
        SwiftyBeaver.debug("urlString = \(urlString)")
        guard let url = URL(string: urlString) else {
            SwiftyBeaver.debug(urlString)
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            SwiftyBeaver.debug("data = \(String(describing: data))")
            SwiftyBeaver.debug("response = \(String(describing: response))")
            SwiftyBeaver.debug("error = \(String(describing: error))")
            return completion(data, response, error)

        }.resume()
    }

    private func treatmentUsers(usersAr: [[String: AnyObject]]) throws {
        //increase name up to usersArray.count
        let requestIncrease = NSFetchRequest<NSFetchRequestResult>(
            entityName: "UserCur"
        )
        let titleSort = NSSortDescriptor(key: "id", ascending: true)
        requestIncrease.sortDescriptors = [titleSort]
        let managedObjectContext =
            CoredataStack.mainContext

        var curI = 0
        for el in usersAr {
            SwiftyBeaver.debug("el = \(el)")
            SwiftyBeaver.debug(
                "el[\"id\"]  = \(String(describing: el["id"] ))  "
            )
            let request = NSFetchRequest<NSFetchRequestResult>(
                entityName: "UserCur"
            )
            request.predicate = NSPredicate(
                format: "(id == %@)",
                argumentArray: [el["id"] ?? ""]
            )
            do {
                let managedObjectContext = CoredataStack.mainContext
                if let fetchedObjects = try managedObjectContext.fetch(request)
                    as? [UserCur]
                {
                    if fetchedObjects.count == 0 {
                        //save new in local database

                        let curUser =
                            NSEntityDescription.insertNewObject(
                                forEntityName: "UserCur",
                                into: managedObjectContext
                            ) as? UserCur
                        curUser?.id = Int64(Int(el["id"]?.int64Value ?? 0))
                        curUser?.positionID = Int64(
                            Int(el["positionID"]?.int64Value ?? 1)
                        )
                        curUser?.registration_timestamp =
                            el["registration_timestamp"]?.int64Value ?? 1
                        curUser?.email = el["email"] as? String
                        curUser?.name = el["name"] as? String
                        curUser?.phone = el["phone"] as? String
                        curUser?.photo = el["photo"] as? String
                        curUser?.position = el["position"] as? String
                        managedObjectContext.performAndWait { () -> Void in
                            if managedObjectContext.hasChanges {
                                do {
                                    try managedObjectContext.save()
                                } catch let error {
                                    SwiftyBeaver.debug(error)
                                }
                            }
                        }
                        curI = curI + 1
                    }
                }
            } catch {
                fatalError("Failed to fetch User: \(error)")
                //return nil
            }
        }
    }

    public func getPositions(
        completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) {
        var urlString = String(format: "%@/positions", ApiManager.baseURL)
        SwiftyBeaver.debug("urlString = \(urlString)")
        guard let url = URL(string: urlString) else {
            SwiftyBeaver.debug(urlString)
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            SwiftyBeaver.debug("data = \(String(describing: data))")
            SwiftyBeaver.debug("response = \(String(describing: response))")
            SwiftyBeaver.debug("error = \(String(describing: error))")
            return completion(data, response, error)

        }.resume()
    }

    public func treatmentPositions(positionsAr: [[String: AnyObject]]) throws {
        //increase name up to usersArray.count
        let requestIncrease = NSFetchRequest<NSFetchRequestResult>(
            entityName: "Position"
        )
        let titleSort = NSSortDescriptor(key: "id", ascending: true)
        requestIncrease.sortDescriptors = [titleSort]
        let managedObjectContext =
            CoredataStack.mainContext

        var curI = 0
        for el in positionsAr {
            SwiftyBeaver.debug("el = \(el)")
            SwiftyBeaver.debug(
                "el[\"id\"]  = \(String(describing: el["id"] ))  "
            )
            let request = NSFetchRequest<NSFetchRequestResult>(
                entityName: "Position"
            )
            request.predicate = NSPredicate(
                format: "(id == %@)",
                argumentArray: [el["id"] ?? ""]
            )
            do {
                let managedObjectContext = CoredataStack.mainContext
                if let fetchedObjects = try managedObjectContext.fetch(request)
                    as? [UserCur]
                {
                    if fetchedObjects.count == 0 {
                        //save new in local database

                        let curUser =
                            NSEntityDescription.insertNewObject(
                                forEntityName: "Position",
                                into: managedObjectContext
                            ) as? Position
                        curUser?.id = Int64(Int(el["id"]?.int64Value ?? 0))
                        curUser?.name = el["name"] as? String
                        curUser?.isSelected = false
                        managedObjectContext.performAndWait { () -> Void in
                            if managedObjectContext.hasChanges {
                                do {
                                    try managedObjectContext.save()
                                } catch let error {
                                    SwiftyBeaver.debug(error)
                                }
                            }
                        }
                        curI = curI + 1
                    }
                }
            } catch {
                fatalError("Failed to fetch User: \(error)")
                //return nil
            }
        }
    }

    public func setUser(
        curPageNumber: Int,
        completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) {
        var urlString = String(
            format: "%@/user?page=%@&per_page=%@",
            ApiManager.baseURL,
            String(describing: curPageNumber),
            String(describing: ApiManager.perPage)
        )
        SwiftyBeaver.debug("urlString = \(urlString)")
        guard let url = URL(string: urlString) else {
            SwiftyBeaver.debug(urlString)
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            SwiftyBeaver.debug("data = \(String(describing: data))")
            SwiftyBeaver.debug("response = \(String(describing: response))")
            SwiftyBeaver.debug("error = \(String(describing: error))")
            return completion(data, response, error)

        }.resume()
    }

    public func getToken(
        completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) {
        var urlString = String(format: "%@/token", ApiManager.baseURL)
        SwiftyBeaver.debug("urlString = \(urlString)")
        guard let url = URL(string: urlString) else {
            SwiftyBeaver.debug(urlString)
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            SwiftyBeaver.debug("data = \(String(describing: data))")
            SwiftyBeaver.debug("response = \(String(describing: response))")
            SwiftyBeaver.debug("error = \(String(describing: error))")
            return completion(data, response, error)

        }.resume()
    }

    /// Register a new user with the required information
    /// - Parameters:
    ///   - name: Username (2-60 characters)
    ///   - email: Valid email according to RFC2822
    ///   - phone: Phone number starting with +380 (Ukraine)
    ///   - positionId: User position ID obtained from GET api/v1/positions
    ///   - photo: JPEG/JPG image of minimum 70x70px, max 5MB
    ///   - token: Registration token
    ///   - completion: Callback with result
    public func registerUser(
        name: String,
        email: String,
        phone: String,
        positionId: Int,
        photo: UIImage,
        token: String,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {

        // Validate input parameters
        guard validateName(name) else {

            completion(.failure(ValidationError.invalidName))
            return
        }

        guard validateEmail(email) else {
            completion(.failure(ValidationError.invalidEmail))
            return
        }

        guard validatePhone(phone) else {
            completion(.failure(ValidationError.invalidPhone))
            return
        }

        guard let photoData = photo.jpegData(compressionQuality: 0.9) else {
            completion(.failure(ValidationError.photoConversionFailed))
            return
        }
        let sizeInMB = Double(photoData.count) / (1024.0 * 1024.0)
        SwiftyBeaver.debug(String(format: "Photo size: %.2f MB", sizeInMB))
        guard validatePhotoSize(photoData) else {
            completion(.failure(ValidationError.photoTooLarge))
            return
        }

        guard validatePhotoResolution(photo) else {
            completion(.failure(ValidationError.photoTooSmall))
            return
        }
        var ss = ""
        if let string = String(decoding: photoData, as: UTF8.self) as? String {
            SwiftyBeaver.debug("photoData data to string: ")  // Output: Hello, world!
            ss = string
        } else {
            SwiftyBeaver.debug("Failed to convert data to string")
        }
        // Create the URL request
        var components = URLComponents()
        components.scheme = "https"
        components.host = "frontend-test-assignment-api.abz.agency"
        components.path = "/api/v1/users"
        components.queryItems = [
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "email", value: email),
            URLQueryItem(name: "phone", value: phone),
            URLQueryItem(name: "position_id", value: "\(positionId)")
//                        URLQueryItem(name: "photo", value: "\(ss)")
        ]
        let url = components.url ?? URL(string: "\(ApiManager.baseURL)/users")!
//        let url = URL(string: "\(ApiManager.baseURL)/users")!
        var mes2 = ""
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        guard let base64String = UserDefaults.standard.string(forKey: "token")
        else {
            SwiftyBeaver.debug("No credentials yet")
            return
        }
        // Set the authorization header with the token
        //            request.setValue("Bearer \(token)", forHTTPHeaderField: "Token")
        // Generate boundary string for multipart/form-data
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(token, forHTTPHeaderField: "Token")
        request.addValue("XSRF-TOKEN=\(token)", forHTTPHeaderField: "Cookie")
        //        let data1 = "Hello, world!".data(using: .utf8)!
        //        if let string = String(decoding: photoData, as: UTF8.self) as? String {
        ////            SwiftyBeaver.debug("photoData data to string: ")  // Output: Hello, world!
        //            ss = string
        //        } else {
        //            SwiftyBeaver.debug("Failed to convert data to string")
        //        }
        //        let parameters = "  -F 'name=\(name)' \\\n  -F 'email=\(email)' \\\n  -F 'phone=\(phone)' \\\n  -F 'position_id=\(positionId)' \\\n  -F 'photo=@thispersondoesnotexist.jpg;type=image/jpeg'"
        //        let postData = parameters.data(using: .utf8)
        let parameters: [String: String] = [
            "name": name,
            "email": email,
            "phone": phone,
            "position_id": "\(positionId)",
            "Token": "\(token)=",
            "Cookie": "XSRF-TOKEN=\(token)",
        ]
        // Create multipart/form-data body
        let body = createRequestBody(
            parameters: parameters,
            boundary: boundary,
            photoData: photoData
        )

        //        let body = createRequestBody(
        //            //        let parameters: [String: Any]  = [
        //            //            "name": name,
        //            //            "email": email,
        //            //            "phone": phone,
        //            //            "position_id": "\(positionId)",
        //            //            "Token": "\(token)=",
        //            //            "Cookie": "XSRF-TOKEN=\(token)"
        //            //        ]
        //            boundary: boundary,
        //            photoData: photoData
        //                //            ]
        //        )
        // Convert parameters to JSON data
        //        let parameters: [String: Any]  = [
        //                "photo": ss
        //            ]
        //        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
        //            SwiftyBeaver.debug("Error serializing parameters")
        //            return
        //        }
        //        SwiftyBeaver.debug("registerUser body: \(postData)")
        request.httpBody = body
        SwiftyBeaver.debug(
            "registerUser String(describing: request.allHTTPHeaderFields): \(request.debugDescription)"
        )
        SwiftyBeaver.debug(
            "registerUser String(describing: request.allHTTPHeaderFields): \(String(describing: request.allHTTPHeaderFields))"
        )
        SwiftyBeaver.debug(
            "registerUser String(describing: request.httpBody): \(String(describing: request.httpBody))"
        )
        // Make the request
        let task = URLSession.shared.dataTask(with: request) {
            data,
            response,
            error in
            SwiftyBeaver.debug("Registration data: \(String(describing: data))")
            let data1 = "Hello, world!".data(using: .utf8)!
            if let string = String(data: (data ?? data1), encoding: .utf8) {
                SwiftyBeaver.debug("data to string: \(string)")  // Output: Hello, world!
            } else {
                SwiftyBeaver.debug("Failed to convert data to string")
            }
            if let data2 = (data as? Data) ?? (data1 as? Data),
               let jsonObject = try? JSONSerialization.jsonObject(with: data2, options: []) as? [String: Any],
               let success = jsonObject["success"] as? Bool,
               success == true {
             // show screen with text
                SwiftyBeaver.info("✅ Success is true")
            } else {
                SwiftyBeaver.warning("❌ Success is false or missing")
                if let data2 = (data as? Data) ?? (data1 as? Data),
                   let jsonObject = try? JSONSerialization.jsonObject(with: data2, options: []) as? [String: Any],
                   let m2 = jsonObject["message"] as? String{
                    mes2 = m2
                }
            }
            SwiftyBeaver.debug(
                "Registration response: \(String(describing: response))"
            )
            SwiftyBeaver.debug(
                "Registration error: \(String(describing: error))"
            )
            if let error = error {
                SwiftyBeaver.debug("Registration failed: \(error)")
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                SwiftyBeaver.debug(
                    "Registration failed httpResponse: \(String(describing: error))"
                )
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                if (401...401).contains(httpResponse.statusCode) {
                    self.getToken(completion: { (data, response, error) in
                        SwiftyBeaver.debug("data = \(String(describing: data))")
                        SwiftyBeaver.debug(
                            "response = \(String(describing: response))"
                        )
                        SwiftyBeaver.debug(
                            "error = \(String(describing: error))"
                        )
                        guard
                            let httpURLResponse = response as? HTTPURLResponse,
                            httpURLResponse.statusCode == 200,
                            let mimeType = response?.mimeType,  //mimeType.hasPrefix("application/json"),
                            let data = data, error == nil

                        else {
                            if (error?.localizedDescription) != nil {
                                SwiftyBeaver.debug(
                                    (error?.localizedDescription)! as String
                                )
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
                                success == 1
                            {
                                SwiftyBeaver.debug(success)
                                if let token2 = json["token"] as? String {
                                    UserDefaults.standard.set(
                                        token2,
                                        forKey: "token"
                                    )
                                    UserDefaults.standard.synchronize()
                                    //token = token2
                                }
                            } else {
                                SwiftyBeaver.debug(json)
                            }
                        } catch let error as NSError {
                            SwiftyBeaver.debug(error.localizedDescription)
                        }

                    })
                }
                completion(
                    .failure(
                        NetworkError.serverError(
                            statusCode: httpResponse.statusCode, message: mes2
                        )
                    )
                )
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            completion(.success(data))
        }

        task.resume()
    }

    // MARK: - Private Methods

    private func validateName(_ name: String) -> Bool {
        return name.count >= 2 && name.count <= 60
    }

    private func validateEmail(_ email: String) -> Bool {
        // Basic email validation - for production use a more robust solution
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    private func validatePhone(_ phone: String) -> Bool {
        // Ukrainian phone format validation +380XXXXXXXXX
        let phoneRegex = "^\\d{12}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone)
    }

    private func validatePhotoSize(_ photoData: Data) -> Bool {
        // Check if photo size is less than 5MB
        let maxSize = 5 * 1024 * 1024  // 5MB in bytes
        return photoData.count <= maxSize
    }

    private func validatePhotoResolution(_ photo: UIImage) -> Bool {
        // Check if photo resolution is at least 70x70px
        return photo.size.width >= 70 && photo.size.height >= 70
    }

    private func createRequestBody(
        parameters: [String: String],
        boundary: String,
        photoData: Data
    ) -> Data {
        var body = Data()

        // Add text parameters
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append(
                "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(
                    using: .utf8
                )!
            )
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        // Add photo data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append(
            "Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n"
                .data(using: .utf8)!
        )
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        let str = String(decoding: photoData, as: UTF8.self)
        //            SwiftyBeaver.debug("createRequestBody photoData to string: \(str)")
        body.append(photoData)
        body.append("\r\n".data(using: .utf8)!)

        // Add closing boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        return body
    }

}

// MARK: - Errors

enum ValidationError: Error {
    case invalidName
    case invalidEmail
    case invalidPhone
    case photoConversionFailed
    case photoTooLarge
    case photoTooSmall
}

enum NetworkError: Error {
    case invalidResponse
    case serverError(statusCode: Int, message: String)
    case noData

    var message: String {
            switch self {
            case .serverError(_, let message):
                return message
            case .invalidResponse:
                return "Invalid response from server"
            case .noData:
                return "No data received"
            }
        }

        var statusCode: Int? {
            switch self {
            case .serverError(let statusCode, _):
                return statusCode
            default:
                return nil
            }
        }
}

enum RegistrationError: Error {
    case invalidName
    case emailTaken
    case weakPassword
    case unknown(String)
}

