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
import CoreData

class MinAreaSliderView: FilterHeaderView {

    static private let fallbackIndex: Int = 1

    static let values: [Float] = {
        var array = [Float(0)]
        array.append(contentsOf: Array(stride(from: Float(30.0), through: Float(120), by: Float(5.0))))
        return array
    }()

    private let feedback = UISelectionFeedbackGenerator()

    private let slider = UISlider()

    init(value: Float) {
        let indexForValue = MinAreaSliderView.indexFrom(arbitraryDistance: value)
        self.value = MinAreaSliderView.values[indexForValue]
        slider.value = Float(indexForValue) / Float(MinAreaSliderView.values.count)

        // If it's unlimited just set it to "max"
        if indexForValue == MinAreaSliderView.values.count - 1 {
            slider.value = 1.0
        }

        super.init()
        tintColor = .lightGreen

        slider.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(slider)
        contentView.topAnchor.constraint(equalTo: slider.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: slider.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: slider.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: slider.bottomAnchor).isActive = true
        slider.addTarget(self, action: #selector(changed), for: .valueChanged)
        updateDistanceLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public private(set) var value: Float {
        didSet {
            if oldValue != value {
                sendActions(for: .valueChanged)
                updateDistanceLabel()
                feedback.prepare()
                feedback.selectionChanged()
            }
        }
    }

    /// Gives the distance the is represented by value.
    ///
    /// - Parameter value: values is in (0...1)
    /// - Returns: distance for value
    static func distanceFrom(sliderValue: Float) -> Float {
        let index = Int(round(sliderValue * Float(MinAreaSliderView.values.count - 1)))
        return MinAreaSliderView.values[index]
    }

    /// Gives a one of the predefined distances in `values` from an
    /// arbitrary distance. The closest one will be used.
    ///
    /// - Parameter arbitraryDistance: any distance what so ever
    /// - Returns: index for the value closest to `arbitraryDistance` in `FilterDistanceView.values`
    static func indexFrom(arbitraryDistance: Float) -> Int {
        let indexes = (0..<MinAreaSliderView.values.count)
        let distances = MinAreaSliderView.values.map { abs($0 - arbitraryDistance) }
        let indexClosesToValue = zip(indexes, distances).min { $0.1 < $1.1 }.map { $0.0 } ?? MinAreaSliderView.fallbackIndex
        return indexClosesToValue
    }

    private func updateDistanceLabel() {
        if value == Float.greatestFiniteMagnitude || Int(value) == 0 {
            headingLabel.text = "Ingen minimum-area"
        } else {
            let attrString = NSMutableAttributedString(string: "Minimum area: ")
            attrString.append(Int32(value).m2Area(foregroundColor: headingLabel.textColor))
            headingLabel.attributedText = attrString
        }
    }

    @objc private func changed() {
        value = MinAreaSliderView.distanceFrom(sliderValue: slider.value)
    }
}
