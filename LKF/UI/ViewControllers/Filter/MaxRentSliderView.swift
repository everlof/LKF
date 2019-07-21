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

class MaxRentSliderView: FilterHeaderView {

    static private let fallbackIndex: Int = 0

    static let values: [Float] = {
        return Array(stride(from: Float(0.0), through: Float(15000.0), by: Float(500.0)))
    }()

    private let feedback = UISelectionFeedbackGenerator()

    private let slider = UISlider()

    init(value: Float) {
        let indexForValue = MaxRentSliderView.indexFrom(arbitraryDistance: value)
        self.value = MaxRentSliderView.values[indexForValue]
        slider.value = Float(indexForValue) / Float(MaxRentSliderView.values.count)

        // If it's unlimited just set it to "max"
        if indexForValue == MaxRentSliderView.values.count - 1 {
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

    public private(set) var value: Float

    func change(value: Float, sendFeedback: Bool, updateSlider: Bool = true) {
        sendActions(for: .valueChanged)

        self.value = value
        updateDistanceLabel()

        if updateSlider {
            slider.setValue(value, animated: false)
        }

        if sendFeedback {
            feedback.prepare()
            feedback.selectionChanged()
        }
    }

    /// Gives the distance the is represented by value.
    ///
    /// - Parameter value: values is in (0...1)
    /// - Returns: distance for value
    static func distanceFrom(sliderValue: Float) -> Float {
        let index = Int(round(sliderValue * Float(MaxRentSliderView.values.count - 1)))
        return MaxRentSliderView.values[index]
    }

    /// Gives a one of the predefined distances in `values` from an
    /// arbitrary distance. The closest one will be used.
    ///
    /// - Parameter arbitraryDistance: any distance what so ever
    /// - Returns: index for the value closest to `arbitraryDistance` in `FilterDistanceView.values`
    static func indexFrom(arbitraryDistance: Float) -> Int {
        let indexes = (0..<MaxRentSliderView.values.count)
        let distances = MaxRentSliderView.values.map { abs($0 - arbitraryDistance) }
        let indexClosesToValue = zip(indexes, distances).min { $0.1 < $1.1 }.map { $0.0 } ?? MaxRentSliderView.fallbackIndex
        return indexClosesToValue
    }

    private func updateDistanceLabel() {
        if value == Float.greatestFiniteMagnitude || Int(value) == 0 {
            headingLabel.text = "Ingen max-hyra"
        } else {
            headingLabel.text = String(format: "Max hyra: %@", Int32(value).asCurrency())
        }
    }

    @objc private func changed() {
        if value != slider.value {
            value = MaxRentSliderView.distanceFrom(sliderValue: slider.value)
            change(value: value, sendFeedback: true, updateSlider: false)
        }
    }
}
