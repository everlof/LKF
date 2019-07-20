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
import CoreLocation
import CoreData

extension Filter {

    var rooms: Set<Int> {
        get {
            guard let raw__rooms = raw__rooms else {
                return Set<Int>()
            }
            return raw__rooms
        }
        set {
            raw__rooms = newValue
        }
    }

    var roomsDescription: String {
        guard let raw__rooms = raw__rooms else {
            return "Inget rumfilter"
        }
        guard !raw__rooms.isEmpty else {
            return "Inget rumfilter"
        }

        func textFor(start: Int, end: Int) -> String {
            return start == end ?
                String(format: "%d rum", start) :
                String(format: "%d-%d rum", start, end)
        }

        var sorted = raw__rooms.sorted()
        sorted.append(sorted.last!)

        var seqStart = sorted.first!
        var strings = [String]()
        zip(sorted, sorted.dropFirst()).forEach { value, nextValue in
            if nextValue - 1 != value {
                strings.append(textFor(start: seqStart, end: value))
                seqStart = nextValue
            }
        }

        if strings.isEmpty {
            strings.append(textFor(start: seqStart, end: sorted.last!))
        }

        return strings.joined(separator: ", ")
    }

    var sorting: Sorting {
        get {
            guard let raw__sorting = raw__sorting else {
                return .newestAscending
            }
            return Sorting(rawValue: raw__sorting) ?? .newestAscending
        }
        set {
            raw__sorting = newValue.rawValue
        }
    }

}

enum Sorting: String, CaseIterable, Codable {
    case newestAscending
    case newestDescending
    case priceAscending
    case priceDescending
    case sizeAscending
    case sizeDescending
}

extension Sorting: CustomStringConvertible {

    var description: String {
        switch self {
        case .priceAscending:
            return "Pris ↑"
        case .priceDescending:
            return "Pris ↓"
        case .newestAscending:
            return "Nyast ↑"
        case .newestDescending:
            return "Nyast ↓"
        case .sizeAscending:
            return "Störst ↑"
        case .sizeDescending:
            return "Störst ↓"
        }
    }

}

extension Filter {

    // MARK: - Helpers to create objects for the filter to act on `Company`

    var fetchRequest: NSFetchRequest<LKFObject> {
        let fetchRequest: NSFetchRequest<LKFObject> = LKFObject.fetchRequest()
        fetchRequest.sortDescriptors = sortDescriptor
        fetchRequest.predicate = predicate
        return fetchRequest
    }

    var sortDescriptor: [NSSortDescriptor] {
        switch sorting {
        case .priceAscending:
            return [NSSortDescriptor(key: #keyPath(LKFObject.cost), ascending: true)]
        case .priceDescending:
            return [NSSortDescriptor(key: #keyPath(LKFObject.cost), ascending: false)]
        case .newestAscending:
            return [
                NSSortDescriptor(key: #keyPath(LKFObject.showDateEnd), ascending: true),
                NSSortDescriptor(key: #keyPath(LKFObject.meta__imported), ascending: true)
            ]
        case .newestDescending:
            return [
                NSSortDescriptor(key: #keyPath(LKFObject.showDateEnd), ascending: false),
                NSSortDescriptor(key: #keyPath(LKFObject.meta__imported), ascending: false)
            ]
        case .sizeAscending:
            return [NSSortDescriptor(key: #keyPath(LKFObject.size), ascending: true)]
        case .sizeDescending:
            return [NSSortDescriptor(key: #keyPath(LKFObject.size), ascending: false)]
        }
    }

    var predicate: NSPredicate {
        let costPredicate = maxRent > 0 ?
            NSPredicate(format: "%K >= %@", #keyPath(LKFObject.cost), NSNumber(value: maxRent)) :
            NSPredicate(value: true)

        let areaPredicate = minArea > 0 ?
            NSPredicate(format: "%K >= %@", #keyPath(LKFObject.size), NSNumber(value: minArea)) :
            NSPredicate(value: true)

        let roomsPredicate = rooms.isEmpty ?
            NSPredicate(value: true) :
            NSPredicate(format: "%K in %@", #keyPath(LKFObject.rooms), rooms)

        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            areaPredicate,
            costPredicate,
            roomsPredicate,
            NSPredicate(format: "%K > %@", #keyPath(LKFObject.showDateEnd), Current.date() as NSDate)
        ])
    }

}
