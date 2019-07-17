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

class RoundButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.width / 2
        layer.masksToBounds = true
    }

}

class RoomsButtonsView: UIControl {

    private static let disabledAlpha: CGFloat = 0.20
    private static let disabledTextAlpha: CGFloat = 0.40

    let stackView = UIStackView()

    let buttons: [RoundButton]

    var enabledRooms = Set<Int>()

    init(enabledRooms: Set<Int>) {
        self.enabledRooms = enabledRooms
        buttons = (0...4).map { nbrRooms in
            let btn = RoundButton(type: .system)
            btn.setTitle(String(nbrRooms + 1), for: .normal)

            btn.titleLabel?.font = UIFont.appFontBold(with: 16)
            if enabledRooms.contains((nbrRooms + 1)) {
                btn.setTitleColor(.darkGreen, for: .normal)
                btn.setBackgroundImage(UIImage(color: .white), for: .normal)
            } else {
                btn.setTitleColor(UIColor.white.withAlphaComponent(RoomsButtonsView.disabledTextAlpha), for: .normal)
                btn.setBackgroundImage(UIImage(color: UIColor.white.withAlphaComponent(RoomsButtonsView.disabledAlpha)), for: .normal)
            }
            btn.widthAnchor.constraint(equalTo: btn.heightAnchor).isActive = true
            btn.widthAnchor.constraint(equalToConstant: 28).isActive = true
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
        if let index = buttons.firstIndex(of: sender) {
            if enabledRooms.contains(index + 1) {
                enabledRooms.remove(index + 1)
            } else {
                enabledRooms.insert(index + 1)
            }

            zip(buttons, 0...4).forEach { (btn, idx) in
                if enabledRooms.contains((idx + 1)) {
                    btn.setTitleColor(.darkGreen, for: .normal)
                    btn.setBackgroundImage(UIImage(color: .white), for: .normal)
                } else {
                    btn.setTitleColor(UIColor.white.withAlphaComponent(RoomsButtonsView.disabledTextAlpha), for: .normal)
                    btn.setBackgroundImage(UIImage(color: UIColor.white.withAlphaComponent(RoomsButtonsView.disabledAlpha)), for: .normal)
                }
            }
            
            sendActions(for: .valueChanged)
        }
    }

}
