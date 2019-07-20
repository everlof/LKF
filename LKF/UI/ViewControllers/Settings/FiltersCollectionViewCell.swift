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

protocol FiltersCollectionViewCellDelegate: class {
    func requestDeletion(of: Filter)
}

class FiltersCollectionViewCell: UICollectionViewCell {

    static let identifier = "FiltersCollectionViewCell"

    weak var delegate: FiltersCollectionViewCellDelegate?

    var filter: Filter?

    lazy var mainDescriptionLabel: Label = {
        let lbl = Label()
        lbl.textStyle = .headline
        return lbl
    }()

    lazy var nbrObjectMatchLabel: Label = {
        let lbl = Label()
        lbl.textStyle = .body
        return lbl
    }()

    lazy var deleteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "baseline_delete_black_24pt")!, for: .normal)
        btn.tintColor = UIColor.lightGray
        btn.addTarget(self, action: #selector(deleteFilter), for: .touchUpInside)
        btn.contentEdgeInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 4
        contentView.backgroundColor = UIColor.lightGreen.withAlphaComponent(0.2)

        contentView.addSubview(mainDescriptionLabel)
        contentView.addSubview(nbrObjectMatchLabel)
        contentView.addSubview(deleteButton)

        mainDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        nbrObjectMatchLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainDescriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 9),
            mainDescriptionLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 18),
            nbrObjectMatchLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 18),
            nbrObjectMatchLabel.topAnchor.constraint(equalTo: mainDescriptionLabel.bottomAnchor, constant: 5),
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 9 - 14),
            deleteButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -18 + 14)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(filter: Filter) {
        self.filter = filter
        mainDescriptionLabel.text = filter.roomsDescription
        let count = (try? filter.managedObjectContext?.count(for: filter.fetchRequest)) ?? 0
        nbrObjectMatchLabel.text = String(format: "%d objekt", count)
    }

    @objc func deleteFilter() {
        guard let filter = filter else { return }
        delegate?.requestDeletion(of: filter)
    }

}
