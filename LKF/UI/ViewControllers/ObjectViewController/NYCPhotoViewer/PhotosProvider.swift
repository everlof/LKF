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

/// A component of your data layer, which might load photos from the cache or network.
final class PhotosProvider {
    typealias Slideshow = [Photo]

    let object: LKFObject

    init(object: LKFObject) {
        self.object = object
    }

    func fetchDemoSlideshow() -> Slideshow {
        return (0...1).map { photo(identifier: $0) }
    }

    /// Simulate fetching a photo from the network.
    /// For simplicity in this demo, errors are not simulated, and the callback is invoked on the main queue.
    func fetchPhoto(url: URL, then completionHandler: @escaping (UIImage?) -> Void) {
        let iv = UIImageView()
        iv.sd_setImage(with: url) { (image, _, _, _) in
            DispatchQueue.main.async {
                completionHandler(image)
            }
        }
    }
}

extension PhotosProvider {
    func photo(identifier: Int) -> Photo {
        switch identifier {
        case 0:
            return Photo(url: URL(string: object.imageUrl!)!,
                         summary: "Områdesbild",
                         credit: "Källa: lkf.se", identifier: 0)

        case 1:
            return Photo(url: URL(string: object.planningImageUrl!)!,
                         summary: "Planlösning",
                         credit: "Källa: lkf.se", identifier: 1)
        default:
            fatalError("Invalid photo-identifier => \(identifier)")
        }
    }
}
