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

class KVView: UIView {

    let stackView = UIStackView()

    let keyLabel = Label()

    let valueLabel = Label()

    init() {
        super.init(frame: .zero)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually

        keyLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        valueLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        keyLabel.setContentHuggingPriority(.init(249), for: .horizontal)
        valueLabel.setContentHuggingPriority(.init(249), for: .horizontal)

        keyLabel.textColor = Color.Text.lightGray
        keyLabel.textStyle = .body

        stackView.addArrangedSubview(keyLabel)
        stackView.addArrangedSubview(valueLabel)
        valueLabel.textColor = UIColor.darkText
        valueLabel.textStyle = .body

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        let leftConstraint = stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 18)
        let topConstraint = stackView.topAnchor.constraint(equalTo: topAnchor, constant: 9)
        let rightConstraint = stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -18)
        let bottomConstraint = stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -9)

        leftConstraint.priority = .init(999)
        topConstraint.priority = .init(999)
        rightConstraint.priority = .init(999)
        bottomConstraint.priority = .init(999)

        NSLayoutConstraint.activate([leftConstraint, topConstraint, rightConstraint, bottomConstraint])
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
