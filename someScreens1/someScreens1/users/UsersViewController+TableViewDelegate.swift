//
//  UsersViewController+TableViewDelegate.swift
//  someScreens1
//
//  Created by andriy kruglyanko on 23.04.2025.
//

import Foundation
import UIKit
import Kingfisher
import SwiftyBeaver

extension UsersViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        SwiftyBeaver.debug("willDisplay curPageNumber = \(curPageNumber), indexPath.row = \(indexPath.row )")
        if indexPath.row == ((Configuration.perPage * curPageNumber) - 1) {
            curPageNumber = curPageNumber + 1
            SwiftyBeaver.debug("willDisplay curPageNumber = \(curPageNumber)")
            portionIsSaved = false
            ApiManager.shared().getUsers(curPageNumber: curPageNumber, completion: {  (data, response, error) in
                SwiftyBeaver.debug("data = \(String(describing: data))")
                SwiftyBeaver.debug("response = \(String(describing: response))")
                SwiftyBeaver.debug("error = \(String(describing: error))")
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

                    SwiftyBeaver.debug(json)
                } catch let error as NSError {
                    SwiftyBeaver.debug(error.localizedDescription)
                }

            })
        }
        (cell as! UserTableViewCell).curImageView.kf.indicatorType = IndicatorType.activity
        if let el =  self.fetchedResultsController?.object(at: indexPath) as? UserCur  {
            guard let _ = el.photo
                else {
                    return
            }
            let urlString =  String(format: el.photo ?? "-")
            let url = URL(string:urlString)!

            _ = (cell as! UserTableViewCell).curImageView.kf.setImage(with: url)

        }
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell is UserTableViewCell {
            (cell as! UserTableViewCell).curImageView.kf.cancelDownloadTask()
        }
    }

    

}
