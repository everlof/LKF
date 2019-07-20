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

class RoomsButtonsView: UIControl {

    private static let disabledAlpha: CGFloat = 0.20

    private static let disabledTextAlpha: CGFloat = 0.40

    private static let color: UIColor = .lightGreen

    let stackView = UIStackView()

    let buttons: [TogglableRoundButton]

    var enabledRooms = Set<Int>() {
        didSet {
            zip(buttons, 1..<Int.max).forEach { button, idx in
                button.isActive = enabledRooms.contains(idx)
            }
        }
    }

    init(enabledRooms: Set<Int>) {
        self.enabledRooms = enabledRooms
        buttons = (0...4).map { nbrRooms in
            let btn = TogglableRoundButton(isActive: enabledRooms.contains((nbrRooms + 1)), text: String(nbrRooms + 1), style: .prominent)
            btn.titleLabel?.font = UIFont.appFont(with: 22)
            return btn
        }
        super.init(frame: .zero)
        buttons.forEach { stackView.addArrangedSubview($0) }
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        buttons.forEach { $0.addTarget(self, action: #selector(toggled), for: .touchUpInside) }

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func toggled(sender: RoundButton) {
        enabledRooms = zip(buttons, 1..<Int.max).reduce(into: Set<Int>()) { array, tuple in
            if tuple.0.isActive {
                array.insert(tuple.1)
            }
        }
        sendActions(for: .valueChanged)
        UISelectionFeedbackGenerator().selectionChanged()
    }

}
