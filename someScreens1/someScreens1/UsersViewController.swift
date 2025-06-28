//
//  UsersViewController.swift
//  someScreens1
//
//  Created by andriy kruglyanko on 23.04.2025.
//

import UIKit
import CoreData
import Kingfisher
import SwiftyBeaver
import Network



class UsersViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var curTableView: UITableView!
    @IBOutlet weak var noUsersImageView: UIImageView!
    @IBOutlet weak var noUsersLabel: UILabel!

    var users = [UserCur]()
    var curPageNumber: Int = 1
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var portionIsSaved: Bool = false
    
    private let refreshControl = UIRefreshControl()

    private let networkManager = NetworkManager.shared
    private var networkObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNetworkObserver()
        setupRefreshControl()

        curTableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "UserTableViewCell")
        initializeFetchedResultsController()
        curPageNumber = 1
        portionIsSaved = false
        
        // Check initial network status
        checkNetworkStatus()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                KingfisherManager.shared.cache.calculateDiskStorageSize { result in
                    switch result {
                    case .success(let size):
                        let sizeInMB = Double(size) / 1024 / 1024
                        let alert = UIAlertController(title: nil, message: String(format: "Kingfisher Disk Cache: %.2fMB", sizeInMB), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Purge", style: .destructive) { _ in

                        })
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//                        self.present(alert, animated: true)
                    case .failure(let error):
                        SwiftyBeaver.debug("Some error: \(error)")
                    }
                }
            }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check network status before making API call
        if networkManager.isConnected {
            loadUsers()
        } else {
            showNoInternetConnection()
        }
        
        curTableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeNetworkObserver()
    }

    // MARK: - Network Monitoring
    
    private func setupNetworkObserver() {
        networkObserver = NotificationCenter.default.addObserver(
            forName: NetworkManager.networkStatusChanged,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleNetworkStatusChange(notification: notification)
        }
    }
    
    private func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        curTableView.refreshControl = refreshControl
    }
    
    @objc private func refreshData() {
        SwiftyBeaver.info("🔄 Refresh control triggered")
        
        // Reset page number for fresh data
        curPageNumber = 1
        
        // Check network before loading
        if networkManager.isConnected {
            loadUsers()
        } else {
            showNoInternetConnection()
            refreshControl.endRefreshing()
        }
    }
    
    private func removeNetworkObserver() {
        if let observer = networkObserver {
            NotificationCenter.default.removeObserver(observer)
            networkObserver = nil
        }
    }
    
    private func handleNetworkStatusChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let isConnected = userInfo["isConnected"] as? Bool,
              let wasConnected = userInfo["wasConnected"] as? Bool else {
            return
        }
        
        SwiftyBeaver.info("📱 UsersViewController: Network status changed: isConnected=\(isConnected), wasConnected=\(wasConnected)")
        
        if !wasConnected && isConnected {
            // Network became available
            SwiftyBeaver.info("✅ Network became available, loading users")
            loadUsers()
        } else if wasConnected && !isConnected {
            // Network became unavailable
            SwiftyBeaver.warning("❌ Network became unavailable, showing no internet connection screen")
            showNoInternetConnection()
            refreshControl.endRefreshing()
        }
    }
    
    private func checkNetworkStatus() {
        SwiftyBeaver.info("🔍 Checking initial network status: \(networkManager.isConnected)")
        if !networkManager.isConnected {
            SwiftyBeaver.warning("❌ No internet connection detected, showing no internet connection screen")
            showNoInternetConnection()
        }
    }
    
    private func showNoInternetConnection() {
        // Check if we're not already showing the no internet connection screen
        if !(navigationController?.viewControllers.last is NoInternetConnectionViewController) {
            SwiftyBeaver.info("🔄 Performing segue to noInternetConnection")
            performSegue(withIdentifier: "noInternetConnection", sender: self)
        } else {
            SwiftyBeaver.info("ℹ️ NoInternetConnectionViewController is already showing")
        }
    }
    
    private func loadUsers() {
        SwiftyBeaver.info("📡 Loading users from API, page: \(curPageNumber)")
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
                    SwiftyBeaver.error("❌ API Error: \((error?.localizedDescription)! as String)")
                }
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
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
                    SwiftyBeaver.info("✅ Received \(arU.count) users from API")
                    DispatchQueue.main.async {
                        self.noUsersLabel.superview?.sendSubviewToBack(self.noUsersLabel)
                        self.noUsersImageView.superview?.sendSubviewToBack(self.noUsersImageView)
                        self.refreshControl.endRefreshing()
                    }
                    do {
                        try self.treatmentUsers(
                            usersCur: arU
                        )
                    } catch {
                        SwiftyBeaver.error("❌ Error treating users: \(error)")
                        DispatchQueue.main.async {
                            self.refreshControl.endRefreshing()
                        }
                    }
                } else {
                    SwiftyBeaver.info("ℹ️ No users received from API")
                    DispatchQueue.main.async {
                        self.noUsersLabel.superview?.bringSubviewToFront(self.noUsersLabel)
                        self.noUsersImageView.superview?.bringSubviewToFront(self.noUsersImageView)
                        self.refreshControl.endRefreshing()
                    }
                }
            } catch let error as NSError {
                SwiftyBeaver.error("❌ JSON parsing error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                }
            }

        })
    }

    //MARK: - fetched controller

    func initializeFetchedResultsController() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserCur")
        let created_atSort = NSSortDescriptor(key: "registration_timestamp", ascending: false)
        request.sortDescriptors = [created_atSort]
        let managedObjectContext =
            CoredataStack.mainContext

        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self


        do {
            try fetchedResultsController.performFetch()
            curTableView.reloadData()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        SwiftyBeaver.debug("user didChange sectionInfo type = \(type)")
        self.curTableView.reloadData()
        switch type {
        case .insert:
            self.curTableView?.performBatchUpdates({
                curTableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
                curTableView.reloadData()
            }, completion: nil)

        case .delete:
            self.curTableView?.performBatchUpdates({
                curTableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
                curTableView.reloadData()
            }, completion: nil)

        case .move:
            if self.curTableView.numberOfSections > 0 {
                self.curTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
            break
        case .update:
            break
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        SwiftyBeaver.debug("controllerWillChangeContent")
        DispatchQueue.main.async {
            self.curTableView.reloadData()
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        SwiftyBeaver.debug("post create edit didChange indexPath type = \(type.rawValue)")
        switch type {
        case .insert:
            DispatchQueue.main.async {
                self.curTableView.reloadData()
            }
            break

        case .delete:
            DispatchQueue.main.async {
                self.curTableView.reloadData()
            }
        case .move:
            self.curTableView.reloadData()
            break
        case .update:
            DispatchQueue.main.async {
                self.curTableView.reloadData()
            }
            break
        @unknown default:
            SwiftyBeaver.debug("@unknown default")
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        SwiftyBeaver.debug("controllerDidChangeContent  fetchedResultsController.fetchedObjects?.count =  \(String(describing: fetchedResultsController.fetchedObjects?.count))")

        DispatchQueue.main.async {
            if self.fetchedResultsController.fetchedObjects?.count ?? 0 > 0 {
                // hide mock
    //            noUsersLabel.sendSubviewToBack(<#T##view: UIView##UIView#>)
                SwiftyBeaver.debug("sendSubviewToBack")
                self.noUsersLabel.superview?.sendSubviewToBack(self.noUsersLabel)
                self.noUsersImageView.superview?.sendSubviewToBack(self.noUsersImageView)
    //            childView.superview?.bringSubviewToFront(childView)
            } else {
                SwiftyBeaver.debug("bringSubviewToFront")
                self.noUsersLabel.superview?.bringSubviewToFront(self.noUsersLabel)
                self.noUsersImageView.superview?.bringSubviewToFront(self.noUsersImageView)
            }
            self.curTableView.reloadData()
            self.curTableView.layoutIfNeeded()
        }
    }

    // MARK: - download

    func treatmentUsers(usersCur: [Dictionary<String, AnyObject>]) throws {
        //increase name up to photosArray.count
        let requestIncrease = NSFetchRequest<NSFetchRequestResult>(entityName: "UserCur")
        let titleSort = NSSortDescriptor(key: "id", ascending: true)
        requestIncrease.sortDescriptors = [titleSort]
//        let managedObjectContext =
//            CoredataStack.mainContext

        var curI = 0
        for el in usersCur {
            SwiftyBeaver.debug("el = \(el)")
            SwiftyBeaver.debug("el[\"id\"]  = \(String(describing: el["id"] ))  ")
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserCur")
            request.predicate = NSPredicate(format: "(id == %@)",
                                            argumentArray: [el["id"] ?? ""])
            do {
                let managedObjectContext = CoredataStack.mainContext
                if let fetchedObjects = try managedObjectContext.fetch(request) as? [UserCur] {
                    if fetchedObjects.count == 0 {
                        //save new in local database

                        let curUser = NSEntityDescription.insertNewObject(forEntityName: "UserCur", into: managedObjectContext) as? UserCur
                        curUser?.id =  Int64(Int(el["id"]?.int64Value ?? 0))
                        curUser?.positionID = Int64(Int(el["position_id"]?.int64Value ?? 1))
                        curUser?.registration_timestamp = el["registration_timestamp"]?.int64Value ?? 1
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
                fatalError("Failed to fetch UserCur: \(error)")
                //return nil
            }
        }
        portionIsSaved  = true
        SwiftyBeaver.debug("portion saved curPageNumber = \(curPageNumber)")
    }

    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        removeNetworkObserver()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
