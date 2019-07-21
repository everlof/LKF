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

import CoreLocation
import UIKit
import Foundation
import CoreData

class ObjectCollectionViewCell: UICollectionViewCell {

    static let identifier = "ObjectCollectionViewCell"

    var object: LKFObject?

    let imageView = UIImageView()

    let addressLabel = Label()

    let sqmLabel = Label()

    let nbrRoomsLabel = Label()

    let rentLabel = Label()

    let locationlabel = Label()

    let objectIDLabel = Label()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        sqmLabel.translatesAutoresizingMaskIntoConstraints = false
        nbrRoomsLabel.translatesAutoresizingMaskIntoConstraints = false
        rentLabel.translatesAutoresizingMaskIntoConstraints = false
        objectIDLabel.translatesAutoresizingMaskIntoConstraints = false
        locationlabel.translatesAutoresizingMaskIntoConstraints = false

        addressLabel.font = UIFont.scaledFont.font(forTextStyle: .headline)
        addressLabel.textColor = UIColor.darkText
        addressLabel.lineBreakMode = .byTruncatingMiddle

        rentLabel.font = UIFont.scaledFont.font(forTextStyle: .body)
        rentLabel.textColor = Color.Text.lightGray

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        nbrRoomsLabel.font = UIFont.scaledFont.font(forTextStyle: .body)
        nbrRoomsLabel.textColor = Color.Text.darkGray
        nbrRoomsLabel.textAlignment = .right

        locationlabel.font = UIFont.scaledFont.font(forTextStyle: .body)
        locationlabel.textColor = Color.Text.lightGray

        objectIDLabel.font = UIFont.scaledFont.font(forTextStyle: .body)
        objectIDLabel.textColor = Color.Text.lightGray

        contentView.addSubview(imageView)
        contentView.addSubview(addressLabel)
        contentView.addSubview(nbrRoomsLabel)
        contentView.addSubview(sqmLabel)
        contentView.addSubview(rentLabel)
        contentView.addSubview(objectIDLabel)
        contentView.addSubview(locationlabel)
        contentView.backgroundColor = .white

        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 110),

            addressLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 8),
            addressLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            addressLabel.rightAnchor.constraint(equalTo: nbrRoomsLabel.leftAnchor, constant: -3),

            nbrRoomsLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            nbrRoomsLabel.lastBaselineAnchor.constraint(equalTo: addressLabel.lastBaselineAnchor),

            imageView.rightAnchor.constraint(equalTo: sqmLabel.leftAnchor, constant: -8),
            sqmLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            rentLabel.bottomAnchor.constraint(equalTo: sqmLabel.topAnchor, constant: -5),
            rentLabel.leadingAnchor.constraint(equalTo: sqmLabel.leadingAnchor),

            objectIDLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            objectIDLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            locationlabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            locationlabel.bottomAnchor.constraint(equalTo: objectIDLabel.topAnchor, constant: -5)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(object: LKFObject) {
        self.object = object
        addressLabel.text = object.address1
        rentLabel.text = object.cost.asCurrency()
        nbrRoomsLabel.text = String(format: "%d rum", object.rooms)
        sqmLabel.attributedText = object.size.m2Area(foregroundColor: Color.Text.lightGray)

        if let imageUrl = URL(string: object.imageUrl ?? "") {
            imageView.sd_setImage(with: imageUrl, completed: nil)
        } else {
            imageView.sd_setImage(with: nil, completed: nil)
        }

        objectIDLabel.text = String(format: "Anmäl innan %@", object.showDateEnd?.presentedString() ?? "-")

        let areaName = object.areaName ?? "Okänd"
        let city = object.meta__city ?? "Okänd"
        locationlabel.text = areaName // String(format: "%@ / %@", areaName, city)
    }

}
