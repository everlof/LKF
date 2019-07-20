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

class LanguageManager {

    private static let currentUserSelectionKey = "currentUserSelection"

    private init() { }

    enum UserSelection {
        case systemDefault
        case userSelection(Locale)
    }

    static var currentUserSelection: UserSelection {
        get {
            guard let data = UserDefaults.standard.data(forKey: currentUserSelectionKey) else { return .systemDefault }
            return (try? JSONDecoder().decode(UserSelection.self, from: data)) ?? .systemDefault
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: currentUserSelectionKey)
            } else {
                fatalError("Failed to write data for new `currentUserSelection` => \(currentUserSelection)")
            }
        }
    }

}

extension LanguageManager.UserSelection {

    var locale: Locale {
        switch self {
        case .systemDefault:
            return Locale.autoupdatingCurrent
        case .userSelection(let locale):
            return locale
        }
    }

}

extension LanguageManager.UserSelection: Codable {

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let string = try container.decode(String.self)
        switch string {
        case "system":
            self = .systemDefault
        default:
            self = .userSelection(Locale(identifier: string))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        switch self {
        case .systemDefault:
            try container.encode(contentsOf: ["system"])
        case .userSelection(let locale):
            try container.encode(contentsOf: [locale.identifier])
        }
    }

}

extension LanguageManager.UserSelection: CaseIterable {

    static var allCases: [LanguageManager.UserSelection] {
        return [
            .systemDefault,
            .userSelection(Locale(identifier: "sv")),
            .userSelection(Locale(identifier: "en"))
        ]
    }
}

extension LanguageManager.UserSelection: Equatable {

    static func == (lhs: LanguageManager.UserSelection, rhs: LanguageManager.UserSelection) -> Bool {
        switch (lhs, rhs) {
        case (.systemDefault, .systemDefault):
            return true
        case (.userSelection(let lhsLocale), .userSelection(let rhsLocale)):
            return lhsLocale == rhsLocale
        default:
            return false
        }
    }

}

extension LanguageManager.UserSelection: CustomStringConvertible {

    var description: String {
        switch self {
        case .systemDefault:
            return String(format: "System default",
                          Current.locale().localizedString(forLanguageCode: Locale.autoupdatingCurrent.languageCode!)!)
        case .userSelection(let locale):
            return Current.locale().localizedString(forLanguageCode: locale.languageCode!)!
        }
    }

}
