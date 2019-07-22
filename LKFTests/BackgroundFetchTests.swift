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

import XCTest
import CoreData
import OHHTTPStubs
@testable import LKF

public func pathContains(_ part: String) -> OHHTTPStubsTestBlock {
    return { req in req.url?.path.contains(part) ?? false }
}

class BackgroundFetchTests: XCTestCase {

    enum Stub {
        case single
        case double
    }

    var nextStub: Stub = .single

    override func setUp() {
        stub(condition: pathContains("AvailableObjects")) { request in
            let filename: String

            switch self.nextStub {
            case .single:
                filename = "single.json.json"
            case .double:
                filename = "double.json.json"
            }

            return OHHTTPStubsResponse(fileAtPath: OHPathForFile(filename, BackgroundFetchTests.self)!,
                                       statusCode: 200,
                                       headers: nil)
        }
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
    }

    func testSimpleFetch() {
        let store = StoreManager(type: .inMemory)
        let e = expectation(description: "Wait for update")

        WebService.shared.update(manager: store) {
            let fr: NSFetchRequest<LKFObject> = LKFObject.fetchRequest()
            let count = try! store.container.viewContext.count(for: fr)
            XCTAssertEqual(1, count)
            e.fulfill()
        }

        wait(for: [e], timeout: 10)
    }

    func testFetchTwiceWithNewObjectSecondTime() {
        let store = StoreManager(type: .inMemory)
        let e = expectation(description: "Wait for update")

        WebService.shared.update(manager: store) {
            let fr: NSFetchRequest<LKFObject> = LKFObject.fetchRequest()
            let count = try! store.container.viewContext.count(for: fr)
            XCTAssertEqual(1, count)

            self.nextStub = .double

            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                WebService.shared.update(manager: store) {
                    let fr: NSFetchRequest<LKFObject> = LKFObject.fetchRequest()
                    let count = try! store.container.viewContext.count(for: fr)
                    XCTAssertEqual(2, count)
                    e.fulfill()
                }
            })
        }

        wait(for: [e], timeout: 10)
    }

    func testBackgroundFetchTwiceWithNewObjectSecondTimeNoFilter() {
        let store = StoreManager(type: .inMemory)
        let notifications = NotificationManager(manager: store)

        let e = expectation(description: "Wait for update")

        WebService.shared.update(manager: store) {
            let fr: NSFetchRequest<LKFObject> = LKFObject.fetchRequest()
            let object = try! store.container.viewContext.fetch(fr).first!
            XCTAssertEqual(object.meta__evaluatedForNotification, true)

            self.nextStub = .double
            DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
                notifications.performFetch(with: { result in
                    XCTAssertEqual(result, .newData)
                    e.fulfill()
                })
            })
        }

        wait(for: [e], timeout: 60)
    }

    func testBackgroundFetchTwiceWithNewObjectSecondTimeWithFilter() {
        let store = StoreManager(type: .inMemory)
        store.fetchingContext.performAndWait {
            _ = Filter(context: store.fetchingContext)
            try! store.fetchingContext.save()
        }

        let notifications = NotificationManager(manager: store)

        let e = expectation(description: "Wait for update")

        WebService.shared.update(manager: store) {
            let fr: NSFetchRequest<LKFObject> = LKFObject.fetchRequest()
            let object = try! store.container.viewContext.fetch(fr).first!
            XCTAssertEqual(object.meta__evaluatedForNotification, true)

            self.nextStub = .double
            DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
                notifications.performFetch(with: { result in
                    XCTAssertEqual(result, .newData)

                    store.fetchingContext.performAndWait {
                        let fr: NSFetchRequest<BGUpdate> = BGUpdate.fetchRequest()
                        let update = try! store.fetchingContext.fetch(fr).first!
                        XCTAssertEqual(update.notificationsSent, 1)
                        XCTAssertEqual(update.objectsBefore, 1)
                        XCTAssertEqual(update.objectsAfter, 2)
                    }
                    e.fulfill()
                })
            })
        }

        wait(for: [e], timeout: 60)
    }

    func testBackgroundFetchTwiceWithNewObjectSecondTimeWithMaxRentFilter() {
        let store = StoreManager(type: .inMemory)
        store.fetchingContext.performAndWait {
            let filter = Filter(context: store.fetchingContext)
            filter.maxRent = 4500
            try! store.fetchingContext.save()
        }

        let notifications = NotificationManager(manager: store)

        let e = expectation(description: "Wait for update")

        WebService.shared.update(manager: store) {
            let fr: NSFetchRequest<LKFObject> = LKFObject.fetchRequest()
            let object = try! store.container.viewContext.fetch(fr).first!
            XCTAssertEqual(object.meta__evaluatedForNotification, true)

            self.nextStub = .double
            DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
                notifications.performFetch(with: { result in
                    XCTAssertEqual(result, .newData)

                    store.fetchingContext.performAndWait {
                        let fr: NSFetchRequest<BGUpdate> = BGUpdate.fetchRequest()
                        let update = try! store.fetchingContext.fetch(fr).first!
                        XCTAssertEqual(update.notificationsSent, 0)
                        XCTAssertEqual(update.objectsBefore, 1)
                        XCTAssertEqual(update.objectsAfter, 2)
                    }
                    e.fulfill()
                })
            })
        }

        wait(for: [e], timeout: 60)
    }

}
