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

class ObjectViewController: UIViewController {

    let object: LKFObject

    let scrollView = UIScrollView()

    let stackView = UIStackView()

    let mainImageView = UIImageView()

    let costKVView = KVView()

    let areaKVView = KVView()

    let roomsKVView = KVView()

    let levelKVView = KVView()

    let buildYearKVView = KVView()

    let availableFromKVView = KVView()

    let showEndKVView = KVView()

    let tapGesture = UITapGestureRecognizer()

    lazy var objectShowcase: ObjectShowcaseView = {
        return ObjectShowcaseView(object: self.object)
    }()

    init(object: LKFObject) {
        self.object = object
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView()

        stackView.axis = .vertical
        stackView.distribution = .fillProportionally

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

        stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true




        if object.url != nil {
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(barButtonSystemItem: .action,
                                target: self,
                                action: #selector(share))
            ]
        } else {
            navigationItem.rightBarButtonItems = []
        }


        #if DEBUG
        navigationItem.rightBarButtonItems?.append(UIBarButtonItem(barButtonSystemItem: .bookmarks,
                                                                   target: self,
                                                                   action: #selector(inspect)))
        #endif
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.separatorGray

        navigationItem.title = object.address1

        stackView.addArrangedSubview(mainImageView)
        stackView.addArrangedSubview(objectShowcase)

        stackView.addArrangedSubview(costKVView)
        stackView.addArrangedSubview(areaKVView)
        stackView.addArrangedSubview(roomsKVView)
        stackView.addArrangedSubview(levelKVView)
        stackView.addArrangedSubview(buildYearKVView)
        stackView.addArrangedSubview(availableFromKVView)
        stackView.addArrangedSubview(showEndKVView)

        zip(0...Int.max, stackView.arrangedSubviews.compactMap { $0 as? KVView }).forEach { idx, v in
            v.backgroundColor = idx % 2 == 0 ? Color.Text.lightGray.withAlphaComponent(0.1) : .clear
        }

        mainImageView.contentMode = .scaleAspectFill
        mainImageView.clipsToBounds = true
        mainImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true

        costKVView.keyLabel.text = "Hyra"
        costKVView.valueLabel.text = object.cost.asCurrency()

        areaKVView.keyLabel.text = "Boarea"
        areaKVView.valueLabel.attributedText = object.size.m2Area(foregroundColor: UIColor.darkText)

        roomsKVView.keyLabel.text = "Antal rum"
        roomsKVView.valueLabel.text = String(format: "%d rum", object.rooms)

        levelKVView.keyLabel.text = "Våning"
        levelKVView.valueLabel.text = String(object.floor)

        if object.rebuiltYear > 0 && object.rebuiltYear != object.builtYear {
            buildYearKVView.keyLabel.text = "Byggår (ombyggt)"
            buildYearKVView.valueLabel.text = String(format: "%d (%d)", object.builtYear, object.rebuiltYear)
        } else {
            buildYearKVView.keyLabel.text = "Byggår"
            buildYearKVView.valueLabel.text = String(object.builtYear)
        }

        availableFromKVView.keyLabel.text = "Tillgänglig"
        availableFromKVView.valueLabel.text = object.availableDate?.presentedString()

        showEndKVView.keyLabel.text = "Anmäl senaste"
        showEndKVView.valueLabel.text = object.showDateEnd?.presentedString()

        if let imageUrl = URL(string: object.imageUrl ?? "") {
            mainImageView.sd_setImage(with: imageUrl, completed: nil)
        } else {
            mainImageView.sd_setImage(with: nil, completed: nil)
        }

        objectShowcase.mapView.addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(didTapMap))
    }

    @objc func share() {
        present(UIActivityViewController(activityItems: [object.url!], applicationActivities: nil),
                animated: true,
                completion: nil)
    }

    @objc func inspect() {
        navigationController?.pushViewController(InspectViewController(object: object), animated: true)
    }

    @objc func didTapMap() {
        navigationController?.pushViewController(SingleObjectMapViewController(object: object), animated: true)
    }

}
