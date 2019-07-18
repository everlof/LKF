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

//

import Foundation
import CoreData

@objc(LKFObject)
public class LKFObject: NSManagedObject {

    var planningDocument: URL? {
        guard let id = id else { return nil }
        return URL(string: String(format: "https://cqwih2.se/his_lkf/HOPAGetPrint4Object.asp?PT=hopamall&O=P&HN1=HDocHierarchyDef2&OC1=HDV_H2_OBJECT&MM1=2&SMP1=100&UV1=1&SM1=3&S1=100&SC1=%%23FFFFFF&ID1=%@&HN2=HDocHierarchyDef2&DFS2=1&UV=0&SC2=%%23008000&OC2=HDV_H2_OBJECT&ID2=%@&HN3=HDocHierarchyDef3&DFO3=1&OC3=HDV_H3_OBJECT&ID3=%@&HN4=HDocHierarchyDef2&DFO4=1&OC4=HDV_H2_OBJECT&ID4=%@&DN4=2", id, id, id, id))
    }

    enum FetchPlanError: Error {
        case wrapped(Error?)
    }

    func fetchPlan(completed: @escaping ((Result<Data, FetchPlanError>) -> Void)) {
        let session = URLSession(configuration: .ephemeral)
        session.dataTask(with: planningDocument!) { (data, response, error) in
            guard let data = data else {
                completed(.failure(.wrapped(error)))
                return
            }

            guard
                let matches = String(data: data, encoding: .utf8)?.matches(for: "ReturnImageP.asp[^\"]+"),
                let first = matches.first else {
                    completed(.failure(.wrapped(error)))
                return
            }

            let urlString = String(format: "https://cqwih2.se/his_lkf/%@", first)
            session.dataTask(with: URL(string: urlString)!) { (data, response, error) in
                if let data = data {
                    completed(.success(data))
                } else {
                    completed(.failure(.wrapped(error)))
                }
            }.resume()
        }.resume()
    }

}
