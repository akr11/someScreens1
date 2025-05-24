//
//  UsersViewController+UITableViewDataSource.swift
//  someScreens1
//
//  Created by andriy kruglyanko on 23.04.2025.
//

import Foundation
import UIKit
import Kingfisher
import SwiftyBeaver

extension UsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        SwiftyBeaver.debug("numberOfRowsInSection \(String(describing: fetchedResultsController.sections?[section].numberOfObjects))")
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        SwiftyBeaver.debug("numberOfSections \(String(describing: fetchedResultsController.sections?.count))")
        return fetchedResultsController.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as? UserTableViewCell
        if let el =  self.fetchedResultsController?.object(at: indexPath) as? UserCur {
            cell?.nameLabel?.text = el.name
            cell?.proffesionLabel.text = el.position
            cell?.emailLabel.text = el.email
            cell?.phoneLabel.text = el.phone
            let urlString =  String(format: el.photo ?? "-")
            if let url = URL(string:urlString) {
                cell?.curImageView.kf.setImage(with: url)
            }
        } else {
            cell?.curImageView?.image = nil
        }
        if ((fetchedResultsController.sections?[indexPath.section].numberOfObjects ?? 0) <= (indexPath.row + 1) &&
            portionIsSaved == true) {
            curPageNumber = curPageNumber + 1
            SwiftyBeaver.debug("next curPageNumber = \(curPageNumber)")
            portionIsSaved = false
            ApiManager.shared().getUsers(curPageNumber: curPageNumber, completion: {  (data, response, error) in
                guard
                    let httpURLResponse = response as? HTTPURLResponse,
                    httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType,  //mimeType.hasPrefix("application/json"),
                    let data = data, error == nil

                else {
                    if (error?.localizedDescription) != nil {
                        SwiftyBeaver.debug((error?.localizedDescription)! as String)
                    }
                    return
                }


                do {
                    let json =
                    try JSONSerialization.jsonObject(
                        with: data,
                        options: .allowFragments
                    ) as! NSDictionary
                    SwiftyBeaver.debug("json = \(json)")
                    if let arU = (json["users"] as? [Dictionary<String, AnyObject>]),
                       arU.count > 0 {
                        DispatchQueue.main.async {
                            self.noUsersLabel.superview?.sendSubviewToBack(self.noUsersLabel)
                            self.noUsersImageView.superview?.sendSubviewToBack(self.noUsersImageView)
                        }
                        do {
                            try self.treatmentUsers(
                                usersCur: arU
                            )
                        } catch {
                            SwiftyBeaver.debug(error)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.noUsersLabel.superview?.bringSubviewToFront(self.noUsersLabel)
                            self.noUsersImageView.superview?.bringSubviewToFront(self.noUsersImageView)
                        }
                    }
                } catch let error as NSError {
                    SwiftyBeaver.debug(error.localizedDescription)
                }

            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    KingfisherManager.shared.cache.calculateDiskStorageSize { result in
                        switch result {
                        case .success(let size):
                            let sizeInMB = Double(size) / 1024 / 1024
                            let alert = UIAlertController(title: nil, message: String(format: "Kingfisher Disk Cache: %.2fMB", sizeInMB), preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Purge", style: .destructive) { _ in

                            })
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                            self.present(alert, animated: true)
                        case .failure(let error):
                            SwiftyBeaver.debug("Some error: \(error)")
                        }
                    }
                }
        }

        return cell ?? tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: IndexPath(row: 0, section: 0))
    }
}
