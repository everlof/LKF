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

class BackgroundFetchTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSimpleFetch() {
        stub(condition: isMethodGET()) { _ in
            return OHHTTPStubsResponse(fileAtPath: OHPathForFile("single.json.json", BackgroundFetchTests.self)!,
                                       statusCode: 200,
                                       headers: nil)
        }

        let store = StoreManager(type: .inMemory)
        let notifications = NotificationManager(container: store.container)

        let e = expectation(description: "Wait for update")

        WebService.shared.update(container: store.container) {
            print("Completed!")
            let fr: NSFetchRequest<LKFObject> = LKFObject.fetchRequest()
            let count = try! store.container.viewContext.count(for: fr)
            XCTAssertEqual(1, count)
            e.fulfill()
        }

        wait(for: [e], timeout: 10)
    }

}
