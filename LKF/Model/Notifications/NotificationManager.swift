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

import Foundation
import UserNotifications
import CoreData
import UIKit

class NotificationManager: NSObject {

    static let shared = NotificationManager(manager: StoreManager.shared)

    let manager: StoreManager

    init(manager: StoreManager) {
        self.manager = manager
        super.init()
    }

    func setup() {
        UNUserNotificationCenter.current().delegate = self
    }

    func checkNotifications(context: NSManagedObjectContext, completed: @escaping (Int) -> Void) {
        var nbrSent = 0
        let sendGroup = DispatchGroup()
        context.refreshAllObjects()
        let allObjectsPredicte: NSFetchRequest<LKFObject> = LKFObject.fetchRequest()
        let allObjects = try! context.fetch(allObjectsPredicte)

        for object in allObjects where !object.meta__evaluatedForNotification {
            let filterFR: NSFetchRequest<Filter> = Filter.fetchRequest()
            let allFilters = try! context.fetch(filterFR)
            for filter in allFilters where !filter.isPrimary {
                if filter.predicate.evaluate(with: object) &&
                    UserDefaults.standard.bool(forKey: SettingsViewController.notificationsKey) {
                    sendGroup.enter()
                    self.send(for: object, completed: {
                        nbrSent += 1
                        sendGroup.leave()
                    })
                    break
                }
            }

            object.meta__evaluatedForNotification = true
        }

        try? context.save()

        sendGroup.notify(queue: DispatchQueue.main, execute: {
            completed(nbrSent)
        })
    }

    func test() {
        let context = manager.container.viewContext
        let fr: NSFetchRequest<LKFObject> = LKFObject.fetchRequest()
        fr.fetchLimit = 1
        if let first = try! context.fetch(fr).first {
            send(for: first, completed: {})
        }
    }

    func send(for object: LKFObject, completed: @escaping () -> Void) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
        let content = UNMutableNotificationContent()

        if let imageData = object.meta__imageData {
            var tmpImagePath = NSTemporaryDirectory()
            tmpImagePath.append(contentsOf: String(format: "%@.jpg", UUID().uuidString))
            imageData.write(toFile: tmpImagePath, atomically: true)
            content.attachments = [
                try! UNNotificationAttachment(identifier: UUID().uuidString,
                                              url: URL(fileURLWithPath: tmpImagePath),
                                              options: [:])
            ]
        }

        let address = object.address1 ?? "Okänd address"
        let area = object.address3 ?? "Okänd plats"
        content.title = String(format: "%@, %@", address, area)
        content.body = String(format: "%d rum, %d kvm, %@ / mån, vån %d",
                              object.rooms,
                              object.size,
                              object.cost.asCurrency(),
                              object.floor)
        content.badge = NSNumber(value: 1)

        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification => \(error)")
            } else {
                print("Scheduled!")
            }
            completed()
        }
    }

    func performFetch(with completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("performFetchWithCompletionHandler")

        let viewContext = manager.container.viewContext
        let fetchRequest: NSFetchRequest<LKFObject> = LKFObject.fetchRequest()

        guard let totalObjectsBefore = try? viewContext.count(for: fetchRequest) else {
            completionHandler(.failed)
            return
        }

        print("totalObjectsBefore => \(totalObjectsBefore)")
        WebService.shared.update(manager: manager, isFromBackground: true) {
            guard let totalObjectsAfter = try? viewContext.count(for: fetchRequest) else {
                completionHandler(.failed)
                return
            }
            
            print("totalObjectsAfter => \(totalObjectsAfter)")

            self.manager.fetchingContext.perform {
                self.manager.fetchingContext.refreshAllObjects()
                self.manager.fetchingContext.automaticallyMergesChangesFromParent = true
                let bgUpdate = BGUpdate(context: self.manager.fetchingContext)
                bgUpdate.objectsBefore = Int32(totalObjectsBefore)
                bgUpdate.objectsAfter = Int32(totalObjectsAfter)
                bgUpdate.when = NSDate()
                try? self.manager.fetchingContext.save()

                if totalObjectsAfter != totalObjectsBefore {
                    ImageRequestQueue.notify(queue: DispatchQueue.main, execute: {
                        self.manager.fetchingContext.perform {
                            print("Object images completed")
                            self.checkNotifications(context: self.manager.fetchingContext, completed: { sendNotifications in
                                self.manager.fetchingContext.performAndWait {
                                    bgUpdate.notificationsSent = Int32(sendNotifications)
                                    try? self.manager.fetchingContext.save()
                                }
                                print("Notifications sent => \(sendNotifications)")
                                completionHandler(.newData)
                            })
                        }
                    })
                } else {
                    print("performFetchWithCompletionHandler -> completionHandler(.noData)")
                    completionHandler(.noData)
                }
            }
        }
    }

}

extension NotificationManager: UNUserNotificationCenterDelegate {

    // The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void)
    {
        print("Responded to notification => \(response)")
        completionHandler()
    }

    // The method will be called on the delegate when the application is launched in response to the user's request to view in-app notification settings. Add UNAuthorizationOptionProvidesAppNotificationSettings as an option in requestAuthorizationWithOptions:completionHandler: to add a button to inline notification settings view and the notification settings view in Settings. The notification will be nil when opened from Settings.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                openSettingsFor notification: UNNotification?) {
        print("Open settings for: \(notification)")
    }

}
