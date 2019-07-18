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

import UIKit
import MapKit

class ObjectShowcaseView: UIView, MKMapViewDelegate {

    let roadLabel = Label()

    let restLabel = Label()

    let mapView = MKMapView()

    let separatorLine = UIView()

    let object: LKFObject

    lazy var annotation: LKFAnnotationProxy = {
        return LKFAnnotationProxy(object: self.object, titleStyle: .none)
    }()

    private let regionRadius: CLLocationDistance = 3000

    init(object: LKFObject) {
        self.object = object
        super.init(frame: .zero)
        roadLabel.translatesAutoresizingMaskIntoConstraints = false
        restLabel.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.translatesAutoresizingMaskIntoConstraints = false

        roadLabel.lineBreakMode = .byTruncatingMiddle
        roadLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        restLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        roadLabel.textStyle = .title2
        restLabel.textStyle = .body

        addSubview(roadLabel)
        addSubview(restLabel)
        addSubview(mapView)
        addSubview(separatorLine)

        roadLabel.topAnchor.constraint(equalTo: topAnchor, constant: 18).isActive = true
        roadLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 18).isActive = true
        roadLabel.rightAnchor.constraint(equalTo: separatorLine.leftAnchor, constant: -4).isActive = true

        roadLabel.bottomAnchor.constraint(equalTo: restLabel.topAnchor, constant: -2).isActive = true
        restLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 18).isActive = true
        restLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18).isActive = true

        mapView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        mapView.rightAnchor.constraint(equalTo: rightAnchor, constant: -0).isActive = true
        mapView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -0).isActive = true
        mapView.heightAnchor.constraint(equalTo: mapView.widthAnchor, multiplier: 0.7).isActive = true

        separatorLine.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separatorLine.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        separatorLine.rightAnchor.constraint(equalTo: mapView.leftAnchor).isActive = true
        separatorLine.widthAnchor.constraint(equalToConstant: 1/UIScreen.main.scale).isActive = true
        separatorLine.backgroundColor = Color.Text.lightGray.withAlphaComponent(0.1)

        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.delegate = self
        mapView.addAnnotation(annotation)
        mapView.setRegion(MKCoordinateRegion(center: annotation.coordinate,
                                             latitudinalMeters: regionRadius * 2.0,
                                             longitudinalMeters: regionRadius * 2.0),
                          animated: true)

        roadLabel.text = object.address1
        restLabel.text = (object.address2 ?? "") + ", " + (object.address3 ?? "")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: MKMarkerAnnotationView.self.description())
        view.markerTintColor = .red
        view.clusteringIdentifier = UUID().uuidString
        view.isEnabled = false
        return view
    }

}
