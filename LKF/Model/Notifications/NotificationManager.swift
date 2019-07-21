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

class NotificationManager: NSObject {

    static let shared = NotificationManager()

    private override init() {
        super.init()
    }

    func setup() {
        UNUserNotificationCenter.current().delegate = self
    }  

    func test() {
        let context = StoreManager.shared.container.viewContext
        let fr: NSFetchRequest<LKFObject> = LKFObject.fetchRequest()
        fr.fetchLimit = 1
//        fr.sortDescriptors = [
//            NSSortDescriptor(keyPath: \LKFObject.size, ascending: false)
//        ]
        let object = try! context.fetch(fr).first!

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
        let area = object.areaName ?? "Okänd plats"
        content.title = String(format: "%@, %@", address, area)
        content.body = String(format: "%d rum, %@ / mån, %d kvm, vån %d",
                              object.rooms,
                              object.cost.asCurrency(),
                              object.size,
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
