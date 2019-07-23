// MIT License
//
// Copyright (c) 2018 David Everlöf
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit
import CoreData
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    lazy var objectCollectionViewController: ObjectCollectionViewController = {
        let context = StoreManager.shared.container.viewContext
        let fetchRequest: NSFetchRequest<Filter> = Filter.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Filter.isPrimary), NSNumber(value: true))
        return ObjectCollectionViewController(style: .root(try! context.fetch(fetchRequest).first!))
    }()

    lazy var objectMapViewController: ObjectMapViewController = {
        let context = StoreManager.shared.container.viewContext
        let fetchRequest: NSFetchRequest<Filter> = Filter.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Filter.isPrimary), NSNumber(value: true))
        return ObjectMapViewController(style: .root(try! context.fetch(fetchRequest).first!))
    }()

    lazy var rootNavController: UINavigationController = {
        return UINavigationController(rootViewController: objectCollectionViewController)
    }()

    func ensureFilter(done: @escaping (() -> Void)) {
        StoreManager.shared.container.performBackgroundTask { ctx in
            let fetchRequest: NSFetchRequest<Filter> = Filter.fetchRequest()
            fetchRequest.predicate =
                NSPredicate(format: "%K == %@", #keyPath(Filter.isPrimary), NSNumber(value: true))
            if let _ = try! ctx.fetch(fetchRequest).first {
                DispatchQueue.main.async(execute: done)
            } else {
                let filter = Filter(context: ctx)
                filter.isPrimary = true
                try! ctx.save()
                DispatchQueue.main.async(execute: done)
            }
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard NSClassFromString("XCTestCase") == nil else {
            return true
        }

        application.setMinimumBackgroundFetchInterval(60 * 60)
        NotificationManager.shared.setup()

        window = UIWindow(frame: UIScreen.main.bounds)
        ensureFilter {
            self.window?.rootViewController = self.rootNavController
            self.window?.tintColor = .white
            self.window?.makeKeyAndVisible()
        }
        checkCoordinates()

        let gradient = CAGradientLayer()
        let sizeLength = UIScreen.main.bounds.size.height * 2
        let defaultNavigationBarFrame = CGRect(x: 0, y: 0, width: sizeLength, height: 64)

        gradient.frame = defaultNavigationBarFrame
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.colors = [
            UIColor.darkGreen.cgColor,
            UIColor.lightGreen.cgColor
        ]

        let img = gradient.image
        UINavigationBar.appearance().barTintColor = UIColor(patternImage: img)
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.appFont(with: 16)
        ]

        return true
    }

    func checkCoordinates() {
        StoreManager.shared.container.performBackgroundTask { context in
            let fr: NSFetchRequest<LKFObject> = LKFObject.fetchRequest()
            fr.predicate =
                NSPredicate(format: "%K == 0 && %K == 0",
                            #keyPath(LKFObject.latitude),
                            #keyPath(LKFObject.longitude))

            do {
                for object in try context.fetch(fr) {
                    object.lookupCoordinates(in: context)
                }
            } catch {
                print("Error => \(error)")
            }
        }
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NotificationManager.shared.performFetch(with: completionHandler)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        WebService.shared.update(manager: StoreManager.shared)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        StoreManager.shared.saveContext()
    }

}

