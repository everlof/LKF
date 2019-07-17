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
import CoreData
import CoreLocation

extension LKFObject {

    func lookupCoordinates(in context: NSManagedObjectContext) {
        guard longitude == 0, latitude == 0 else { return }

        guard
            let address1 = address1,
            let address2 = address2,
            let address3 = address3 else { return }

        CLGeocoder().geocodeAddressString(
            String(format: "%@, %@, %@, Sweden", address1, address2, address3)) { placemarks, error in
                if let error = error {
                    print("Error => \(error)")
                } else {
                    context.performAndWait {
                        self.latitude = placemarks?.first?.location?.coordinate.latitude ?? 0
                        self.longitude = placemarks?.first?.location?.coordinate.longitude ?? 0
                        try! context.save()
                    }
                }
        }
    }

}
