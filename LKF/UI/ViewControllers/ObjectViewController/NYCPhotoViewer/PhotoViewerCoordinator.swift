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

import NYTPhotoViewer

/// Coordinates interaction between the application's data layer and the photo viewer component.
final class PhotoViewerCoordinator: NYTPhotoViewerDataSource {
    let slideshow: [NYTPhotoBox]
    let provider: PhotosProvider

    lazy var photoViewer: NYTPhotosViewController = {
        return NYTPhotosViewController(dataSource: self)
    }()

    init(provider: PhotosProvider) {
        self.provider = provider
        self.slideshow = provider.fetchDemoSlideshow().map { NYTPhotoBox($0) }
        fetchPhotos()
    }

    func fetchPhotos() {
        for box in slideshow {
            provider.fetchPhoto(photo: box.value) { [weak self] (result) in
                box.image = result
                self?.photoViewer.update(box)
            }
        }
    }

    // MARK: NYTPhotoViewerDataSource
    @objc
    var numberOfPhotos: NSNumber? {
        return NSNumber(integerLiteral: slideshow.count)
    }

    @objc
    func index(of photo: NYTPhoto) -> Int {
        guard let box = photo as? NYTPhotoBox else { return NSNotFound }
        return slideshow.firstIndex(where: { $0.value.identifier == box.value.identifier }) ?? NSNotFound
    }

    @objc
    func photo(at index: Int) -> NYTPhoto? {
        guard index < slideshow.count else { return nil }
        return slideshow[index]
    }
}
