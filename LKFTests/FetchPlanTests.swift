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
@testable import LKF

class FetchPlanTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchPlan() {
        let store = StoreManager(type: .inMemory)
        let ctx = store.container.newBackgroundContext()

        ctx.performAndWait {
            let object = LKFObject(context: ctx)
            object.id = "6281-03-0003"
            try! ctx.save()
        }

        let fr: NSFetchRequest<LKFObject> = LKFObject.fetchRequest()
        let object = try! store.container.viewContext.fetch(fr).first!

        let waitForResponse = expectation(description: "Wait for request")

        object.fetchPlan { result in
            switch result {
            case .success(let imageData):
                print("Data => \(imageData)")
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            waitForResponse.fulfill()
        }

        wait(for: [waitForResponse], timeout: 15.0)
    }

}
