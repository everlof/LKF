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

import Foundation

struct World {
    var calendar = Calendar.autoupdatingCurrent
    var date = { Date() }
    var locale = { LanguageManager.currentUserSelection.locale }
    var timeZone = TimeZone.autoupdatingCurrent

    func localized(_ key: String) -> String {
        let lprojPath = Bundle.main.path(forResource: locale().languageCode, ofType: "lproj")!
        let localizedBundle = Bundle(path: lprojPath)!
        return localizedBundle.localizedString(forKey: key, value: nil, table: nil)
    }

}

#if DEBUG
var Current = World() // swiftlint:disable:this identifier_name
#else
let Current = World() // swiftlint:disable:this identifier_name
#endif
