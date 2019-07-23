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
import MapKit

class LKFAnnotationProxy: NSObject, MKAnnotation {
    let object: LKFObject
    let titleStyle: TitleStyle

    enum TitleStyle {
        case address
        case none
    }

    init(object: LKFObject, titleStyle: TitleStyle) {
        self.object = object
        self.titleStyle = titleStyle
    }

    public var title: String? {
        switch titleStyle {
        case .address:
            return object.address1
        case .none:
            return nil
        }
    }

    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: object.latitude)!,
                                      longitude: CLLocationDegrees(exactly: object.longitude)!)
    }

}

extension LKFObject: MKAnnotation {

    public var title: String? {
        return address1 ?? "Okänd"
    }

    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: latitude)!,
                                      longitude: CLLocationDegrees(exactly: longitude)!)
    }

}
