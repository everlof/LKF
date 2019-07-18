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
import NYTPhotoViewer

/// A box allowing NYTPhotoViewer to consume Swift value types from our codebase.
final class NYTPhotoBox: NSObject, NYTPhoto {

    let value: Photo

    init(_ photo: Photo) {
        value = photo
    }

    // MARK: NYTPhoto
    var image: UIImage?
    var imageData: Data?
    var placeholderImage: UIImage?

    var attributedCaptionTitle: NSAttributedString?

    var attributedCaptionSummary: NSAttributedString? {
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                          NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: value.summary, attributes: attributes)
    }

    var attributedCaptionCredit: NSAttributedString? {
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.gray,
                          NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote)]
        return NSAttributedString(string: value.credit, attributes: attributes)
    }
}

// MARK: NSObject Equality
extension NYTPhotoBox {
    @objc
    override func isEqual(_ object: Any?) -> Bool {
        guard let otherPhoto = object as? NYTPhotoBox else { return false }
        return value.identifier == otherPhoto.value.identifier
    }
}
