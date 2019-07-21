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


extension LKFObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LKFObject> {
        return NSFetchRequest<LKFObject>(entityName: "LKFObject")
    }

    @NSManaged public var address1: String?
    @NSManaged public var address2: String?
    @NSManaged public var address3: String?
    @NSManaged public var areaId: String?
    @NSManaged public var areaName: String?
    @NSManaged public var availableDate: NSDate?
    @NSManaged public var balcony: Bool
    @NSManaged public var builtYear: Int32
    @NSManaged public var cost: Int32
    @NSManaged public var dateChanged: NSDate?
    @NSManaged public var dateCreated: NSDate?
    @NSManaged public var dateImported: NSDate?
    @NSManaged public var desc: String?
    @NSManaged public var directSearch: Bool
    @NSManaged public var elevator: Bool
    @NSManaged public var meta__evaluatedForNotification: Bool
    @NSManaged public var flatno: String?
    @NSManaged public var floor: Int32
    @NSManaged public var focus: Bool
    @NSManaged public var id: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var meta__city: String?
    @NSManaged public var meta__generatedPlanDocument: NSData?
    @NSManaged public var meta__imported: NSDate?
    @NSManaged public var moveInDate: NSDate?
    @NSManaged public var moveOutDate: NSDate?
    @NSManaged public var objectGroup: Int32
    @NSManaged public var objectType: Int32
    @NSManaged public var planningDescription: String?
    @NSManaged public var planningImageUrl: String?
    @NSManaged public var price: Int32
    @NSManaged public var randomSort: Bool
    @NSManaged public var rebuiltYear: Int32
    @NSManaged public var residentsOnly: Bool
    @NSManaged public var rooms: Int32
    @NSManaged public var showDateEnd: NSDate?
    @NSManaged public var showDateStart: NSDate?
    @NSManaged public var showWeb: Bool
    @NSManaged public var size: Int32
    @NSManaged public var stateId: String?
    @NSManaged public var stateName: String?
    @NSManaged public var streetViewHeading: Double
    @NSManaged public var streetViewPitch: Double
    @NSManaged public var streetViewZoom: Double
    @NSManaged public var url: String?
    @NSManaged public var meta__imageData: NSData?

}
