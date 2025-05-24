//
//  AppDelegate.swift
//  someScreens1
//
//  Created by andriy kruglyanko on 22.04.2025.
//

import UIKit
import CoreData
import SwiftyBeaver

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        loggerSwiftyBeaverSetttingsSetup()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "someScreens1")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - SwiftyBeaver

    func loggerSwiftyBeaverSetttingsSetup() {
        // add log destinations. at least one is needed!
        let console = ConsoleDestination()  // log to Xcode Console
        let file = FileDestination()  // log to default swiftybeaver.log file
        console.format = "$DHH:mm:ss.SSS$d > $n > $F> $l > $M"

        // use custom format and set console output to short time, log level & message
//        console.format = "$DHH:mm:ss$d $L $M"
        // or use this for JSON output: console.format = "$J"

        // In Xcode 15, specifying the logging method as .logger to display color, subsystem, and category information in the console.(Relies on the OSLog API)
//        console.logPrintWay = .logger(subsystem: "Main", category: "UI")
        // If you prefer not to use the OSLog API, you can use SwiftyBeaver.debug instead.
        // console.logPrintWay = .SwiftyBeaver.debug

        // add the destinations to SwiftyBeaver
        SwiftyBeaver.addDestination(console)
        SwiftyBeaver.addDestination(file)

        // Now let’s log!
        SwiftyBeaver.verbose("not so important")  // prio 1, VERBOSE in silver
        SwiftyBeaver.debug("something to debug")  // prio 2, DEBUG in green
        SwiftyBeaver.info("a nice information")   // prio 3, INFO in blue
        SwiftyBeaver.warning("oh no, that won’t be good")  // prio 4, WARNING in yellow
        SwiftyBeaver.error("ouch, an error did occur!")  // prio 5, ERROR in red

        // log anything!
        SwiftyBeaver.verbose(123)
        SwiftyBeaver.info(-123.45678)
        SwiftyBeaver.warning(Date())
        SwiftyBeaver.error(["I", "like", "logs!"])
        SwiftyBeaver.error(["name": "Mr Beaver", "address": "7 Beaver Lodge"])

        // optionally add context to a log message
//        console.format = "$L: $M $X"
        SwiftyBeaver.debug("age", context: 123)  // "DEBUG: age 123"
        SwiftyBeaver.info("my data", context: [1, "a", 2]) // "INFO: my data [1, \"a\", 2]"
    }

}

extension UINavigationController {
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
            popToViewController(vc, animated: animated)
        }
    }
}

