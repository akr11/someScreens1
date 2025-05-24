//
//  SignUpViewController+UITableViewDataSource.swift
//  someScreens1
//
//  Created by andriy kruglyanko on 26.04.2025.
//

import Foundation
import UIKit
import SwiftyBeaver

extension SignUpViewController: UITableViewDataSource {

//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        SwiftyBeaver.debug("numberOfRowsInSection \(String(describing: fetchedResultsController.sections?[section].numberOfObjects))")
//        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
//    }

    func numberOfSections(in tableView: UITableView) -> Int {
        SwiftyBeaver.debug("numberOfSections \(String(describing: fetchedResultsController.sections?.count))")
        return fetchedResultsController.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        SwiftyBeaver.debug("numberOfRowsInSection \(String(describing: fetchedResultsController.sections?[section].numberOfObjects))")
            return fetchedResultsController.sections?[section].numberOfObjects ?? 0 //options.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RadioButtonCell", for: indexPath) as! RadioButtonCell
            cell.configure(with: self.fetchedResultsController?.object(at: indexPath) as! Position)
            return cell
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            // Update selection
//            for i in 0..<options.count {
//                options[i].isSelected = (i == indexPath.row)
//            }
            for i in 0..<(fetchedResultsController.sections?[indexPath.section].numberOfObjects ?? 0) {
                SwiftyBeaver.debug("i = \(i), indexPath.row = \(indexPath.row)")
                if let el = self.fetchedResultsController?.object(at: IndexPath(row: i, section: indexPath.section)) as? Position {
                    SwiftyBeaver.debug("2 i = \(i), indexPath.row = \(indexPath.row)")
                    el.isSelected = (i == indexPath.row)
                    if el.isSelected {
                        SwiftyBeaver.debug("3 i = \(i), indexPath.row = \(indexPath.row)")
                        selectedPos = el
                    }
                    let managedObjectContext = CoredataStack.mainContext
                    managedObjectContext.performAndWait { () -> Void in
                        do {
                            try managedObjectContext.save()
                        } catch {
                            SwiftyBeaver.debug(error)
                        }
                    }
                }
            }
            initializeFetchedResultsController()
            tableView.reloadData()
        }

}
