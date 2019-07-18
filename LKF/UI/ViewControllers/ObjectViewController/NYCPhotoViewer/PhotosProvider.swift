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
        return (0...2).map { photo(identifier: $0) }
    }

    /// Simulate fetching a photo from the network.
    /// For simplicity in this demo, errors are not simulated, and the callback is invoked on the main queue.
    func fetchPhoto(photo: Photo, then completionHandler: @escaping (UIImage?) -> Void) {
        switch photo.style {
        case .document:
            if let data = photo.object.meta__generatedPlanDocument {
                DispatchQueue.main.async {
                    completionHandler(UIImage(data: data as Data))
                }
            } else {
                object.fetchPlan { result in
                    switch result {
                    case .success(let data):
                        DispatchQueue.main.async {
                            completionHandler(UIImage(data: data))
                        }
                    case .failure:
                        break
                    }
                }
            }
        case .main:
            let iv = UIImageView()
            if let url = URL(string: photo.object.imageUrl ?? "") {
                iv.sd_setImage(with: url) { (image, _, _, _) in
                    DispatchQueue.main.async {
                        completionHandler(image)
                    }
                }
            }
        case .plan:
            let iv = UIImageView()
            if let url = URL(string: photo.object.planningImageUrl ?? "") {
                iv.sd_setImage(with: url) { (image, _, _, _) in
                    DispatchQueue.main.async {
                        completionHandler(image)
                    }
                }
            }
        }
    }
}

extension PhotosProvider {
    func photo(identifier: Int) -> Photo {
        switch identifier {
        case 0:
            return Photo(object: object,
                         style: .main,
                         summary: "Områdesbild",
                         credit: "Källa: lkf.se",
                         identifier: 0)

        case 1:
            return Photo(object: object,
                         style: .plan,
                         summary: "Planlösning",
                         credit: "Källa: lkf.se",
                         identifier: 1)
        case 2:
            return Photo(object: object,
                         style: .document,
                         summary: "Objektdokument",
                         credit: "Källa: lkf.se",
                         identifier: 2)
        default:
            fatalError("Invalid photo-identifier => \(identifier)")
        }
    }
}
