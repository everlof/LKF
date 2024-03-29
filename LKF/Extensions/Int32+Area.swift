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

extension NSAttributedString {

    static func m2(foregroundColor: UIColor) -> NSAttributedString {
        let sqmText = NSMutableAttributedString(string: String(format: "m"), attributes: [
            NSAttributedString.Key.font: UIFont.scaledFont.font(forTextStyle: .body),
            NSAttributedString.Key.foregroundColor: foregroundColor
        ])

        sqmText.append(NSAttributedString(string: "2", attributes: [
            NSAttributedString.Key.font: UIFont.scaledFont.font(forTextStyle: .caption2),
            NSAttributedString.Key.foregroundColor: foregroundColor,
            NSAttributedString.Key.baselineOffset: 6
        ]))

        return sqmText
    }

}

extension Int32 {

    func m2Area(foregroundColor: UIColor) -> NSAttributedString {
        let sqmText = NSMutableAttributedString(string: String(format: "%d m", self), attributes: [
            NSAttributedString.Key.font: UIFont.scaledFont.font(forTextStyle: .body),
            NSAttributedString.Key.foregroundColor: foregroundColor
        ])

        sqmText.append(NSAttributedString(string: "2", attributes: [
            NSAttributedString.Key.font: UIFont.scaledFont.font(forTextStyle: .caption2),
            NSAttributedString.Key.foregroundColor: foregroundColor,
            NSAttributedString.Key.baselineOffset: 6
        ]))

        return sqmText
    }



}
