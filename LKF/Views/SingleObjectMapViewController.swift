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

class SingleObjectMapViewController: UIViewController {

    let object: LKFObject

    let mapView = MKMapView()

    private let regionRadius: CLLocationDistance = 2000

    lazy var annotation: LKFAnnotationProxy = {
        return LKFAnnotationProxy(object: self.object, titleStyle: .none)
    }()

    init(object: LKFObject) {
        self.object = object
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.addAnnotation(annotation)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)

        navigationItem.rightBarButtonItem =
            UIBarButtonItem(image: UIImage(named: "baseline_location_searching_black_24pt"),
                            style: .plain,
                            target: self,
                            action: #selector(centerAnimated))

        NSLayoutConstraint.activate([
            mapView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.rightAnchor.constraint(equalTo: view.rightAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        centerNotAnimated()
    }

    @objc func centerAnimated() {
        center(animated: true)
    }

    @objc func centerNotAnimated() {
        center(animated: false)
    }

    private func center(animated: Bool) {
        mapView.setRegion(MKCoordinateRegion(center: annotation.coordinate,
                                             latitudinalMeters: regionRadius * 2.0,
                                             longitudinalMeters: regionRadius * 2.0),
                          animated: animated)
    }

}
