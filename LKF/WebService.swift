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
import UIKit
import CoreData

var ImageRequestQueue = DispatchGroup()

extension LKFObject {

    func populate(from other: StructObject, in context: NSManagedObjectContext, isFromBackground: Bool) {
        id = other.id
        objectGroup = Int32(other.objectgroup)
        objectType = Int32(other.objecttype)
        showDateStart = other.showdatestart as NSDate?
        showDateEnd = other.showdateend as NSDate?
        moveInDate = other.moveindate as NSDate?
        moveOutDate = other.moveoutdate as NSDate?
        availableDate = other.availabledate as NSDate?
        address1 = other.address1
        address2 = other.address2
        address3 = other.address3
        cost = Int32(other.cost)
        price = Int32(other.price)
        size = Int32(other.size)
        rooms = Int32(other.rooms)
        floor = Int32(other.floor)
        desc = other.description
        planningDescription = other.planningdescription
        builtYear = Int32(other.builtyear ?? 0)
        rebuiltYear = Int32(other.rebuiltyear ?? 0)
        flatno = other.flatno
        url = other.url?.absoluteString
        imageUrl = other.imageurl.absoluteString
        planningImageUrl = other.planningimageurl.absoluteString
        stateId = other.stateid
        stateName = other.statename
        areaId = other.areaid
        areaName = other.areaname
        streetViewPitch = other.streetviewpitch
        streetViewHeading = other.streetviewheading
        streetViewZoom = other.streetviewzoom
        showWeb = other.showweb
        directSearch = other.directsearch
        randomSort = other.randomsort
        residentsOnly = other.residentsonly
        focus = other.focus
        elevator = other.elevator
        balcony = other.balcony
        dateCreated = other.datecreated as NSDate?
        dateChanged = other.datechanged as NSDate?
        dateImported = other.dateimported as NSDate?
        meta__krPerKvm = cost / size

        managedObjectContext.map { lookupCoordinates(in: $0) }

        if !isFromBackground && !meta__evaluatedForNotification {
            meta__evaluatedForNotification = true
        }

        if let imageUrlString = imageUrl,
            let imageUrl = URL(string: imageUrlString), meta__imageData == nil  {
            ImageRequestQueue.enter()
            URLSession(configuration: .ephemeral).dataTask(with: imageUrl, completionHandler: { data, response, error in
                if let data = data, error == nil {
                    context.performAndWait {
                        self.meta__imageData = data as NSData
                        try? context.save()
                        ImageRequestQueue.leave()
                        print("Notification image written")
                    }
                } else {
                    print("Didn't get image, something went wrong => \(error)")
                    ImageRequestQueue.leave()
                }
            }).resume()
        }

        if meta__generatedPlanDocument == nil {
            print("Requesting documentData for \(id!)")
            fetchPlan { result in
                switch result {
                case .success(let data):
                    context.performAndWait {
                        self.meta__generatedPlanDocument = data as NSData?
                        try? context.save()
                        print("DocumentData saved for \(self.id!)")
                    }
                case .failure(let error):
                    print("Failed to fetch documentData saved for: \(error)")
                }
            }
        }

        guard meta__imported == nil else {
            return
        }

        // First time LKFObject is created
        meta__imported = NSDate()
    }

}

enum LKFObjectType: Int {
    case radhus1 = 71
    case radhus2 = 70
    case plus55NoHomelivingKids = 6
    case regular = 7

    var isRadhus: Bool {
        return self == .radhus1 || self == .radhus2
    }
}

struct StructObject: Codable {
    let id: String // "1305-97-0121\",
    let objectgroup: Int // 1,
    let objecttype: Int // 7,
    let showdatestart: Date? // "2019-07-01T00:00:00\",
    let showdateend: Date? // "2019-07-06T00:00:00\",
    let moveindate: Date? // "2019-10-01T00:00:00\",
    let moveoutdate: Date? // null,
    let availabledate: Date // "2019-10-01T00:00:00\",
    let address1: String // "Örnvägen 102\",
    let address2: String // "227 31\",
    let address3: String // "Lund\",
    let cost: Int // 6469,
    let price: Int //  0,
    let size: Int // 77,
    let rooms: Int // 3,
    let floor: Int // 2,
    let description: String?
    let planningdescription: String?
    let builtyear: Int?
    let rebuiltyear: Int?
    let flatno: String?
    let url: URL? // \":\"http://marknad.lkf.se/HSS/Object/Ob...b7e2cb1e-03c4-4a33-a2f7-a7d516c30b6a\",
    let imageurl: URL // \":\"https://marknad.lkf.se/Globa:..7-0121\",
    let planningimageurl: URL // \":\"https://marknad.lkf.se/.....Global/F\",
    let stateid: String // \":\"PUBLISHED\",
    let statename: String // \":\"Publicerat\",
    let areaid: String // \":\"AREA_134\",
    let areaname: String // \":\"Lövsångaren 5 m fl\",
    let latitude: Double // :0.0,
    let longitude: Double // \":0.0,
    let streetviewpitch: Double // \":0.0,
    let streetviewheading: Double // \":0.0,
    let streetviewzoom: Double // \":0.0,
    let showweb: Bool // \":true,
    let directsearch: Bool // \":false,
    let randomsort: Bool // \":false,
    let residentsonly: Bool // \":false,
    let focus: Bool // \":false,
    let elevator: Bool // \":false,
    let balcony: Bool // \":true,
    let datecreated: Date? // \":null,
    let datechanged: Date? // \":\"2019-07-01T08:06:58.67\",
    let dateimported: Date? // \":\"2019-07-05T04:32:56.523\"
}

class WebService {

    static let shared = WebService()

    private init() { }

    let session = URLSession.init(configuration: .ephemeral)

    let apiEndpoint = URL(string: "https://www.lkf.se/")!

    func update(manager: StoreManager, isFromBackground: Bool = false, complete: (() -> Void)? = nil) {
        list { result in
            switch result {
            case .success(let structObjects):
                manager.fetchingContext.perform {
                    for structObject in structObjects {
                        let fr: NSFetchRequest<LKFObject> = LKFObject.fetchRequest()
                        fr.predicate = NSPredicate(format: "id == %@", structObject.id)

                        do {
                            if let object = try manager.fetchingContext.fetch(fr).first {
                                object.populate(from: structObject,
                                                in: manager.fetchingContext,
                                                isFromBackground: isFromBackground)
                            } else {
                                LKFObject(context: manager.fetchingContext)
                                    .populate(from: structObject,
                                              in: manager.fetchingContext,
                                              isFromBackground: isFromBackground)
                            }
                        } catch {
                            continue
                        }
                    }

                    try? manager.fetchingContext.save()
                    DispatchQueue.main.async {
                        complete?()
                    }
                }
            case .failure(let error):
                print("Received error when updating => \(error)")
                DispatchQueue.main.async {
                    complete?()
                }
            }
        }
    }

    func list(complete: @escaping (Result<[StructObject], Error>) -> Void) {
        var components = URLComponents(string: apiEndpoint.appendingPathComponent("api/AvailableObjects/Type/").absoluteString)!
        components.queryItems = [
            URLQueryItem(name: "id", value: "1")
        ]
        base(request: URLRequest(url: components.url!), complete: complete)
    }

    private func base<Response>(path: String, complete: @escaping (Result<Response, Error>) -> Void) where Response: Decodable {
        base(request: URLRequest(url: apiEndpoint.appendingPathComponent(path)), complete: complete)
    }

    private func base<Response>(request: URLRequest, complete: @escaping (Result<Response, Error>) -> Void) where Response: Decodable {
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                complete(.failure(error))
            } else {
                complete(Result<Response, Error> {
                    let decoder = JSONDecoder()

                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

                    let dateFormatterWithMS = DateFormatter()
                    dateFormatterWithMS.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"

                    decoder.dateDecodingStrategy = .custom({ decoder -> Date in
                        let container = try decoder.singleValueContainer()
                        let dateString = try container.decode(String.self)

                        if let date = dateFormatter.date(from: dateString) {
                            return date
                        }

                        if let date = dateFormatterWithMS.date(from: dateString) {
                            return date
                        }

                        return Date()
                    })
                    
                    let strings = try decoder.decode([String].self, from: ("[" + String(data: data!, encoding: .utf8)! + "]").data(using: .utf8)!)
                    return try decoder.decode(Response.self, from: strings[0].data(using: .utf8)!)
                })
            }
        }.resume()
    }

}
