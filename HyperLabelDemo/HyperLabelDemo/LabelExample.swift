//
// The MIT License (MIT)
//
// Copyright (c) 2015-present Badoo Trading Limited.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import HyperLabel

final class LabelExample {
    let title: String
    let factory: () -> UIView

    init(title: String, factory: @escaping () -> UIView) {
        self.title = title
        self.factory = factory
    }
}

extension Array where Element == LabelExample {
    static func makeExamples() -> [LabelExample] {
        return [
            LabelExample(title: "Exact touchable area") {
                HyperLabel.makeDemoLabel(extendLinkTouchArea: false)
            },
            LabelExample(title: "Extended touchable area") {
                HyperLabel.makeDemoLabel(extendLinkTouchArea: true)
            },
            LabelExample(title: "Any UILabel subclass") {
                CustomLabelSubclass.makeDemoLabel()
            },
        ]
    }
}

// MARK: - HyperLabel example

private extension HyperLabel {
    static func makeDemoLabel(extendLinkTouchArea: Bool) -> HyperLabel {
        let label = HyperLabel()
        label.numberOfLines = 0
        label.extendsLinkTouchArea = extendLinkTouchArea
        label.additionalLinkAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.red,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]

        let text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        label.text = text
        let firstLinkRange = text.range(of: "consectetur adipiscing elit")!
        label.addLink(withRange: firstLinkRange, accessibilityIdentifier: "first-link") {
            print("first link pressed")
        }

        let secondLinkRange = text.range(of: "minim veniam")!
        label.addLink(withRange: secondLinkRange, accessibilityIdentifier: "second-link") {
            print("second link pressed")
        }

        return label
    }
}

// MARK: - Custom subclass example

private final class CustomLabelSubclass: UILabel {}
extension CustomLabelSubclass: HyperLabelProtocol {}

private extension CustomLabelSubclass {
    static func makeDemoLabel() -> CustomLabelSubclass {
        let label = CustomLabelSubclass()
        label.initializeHyperLabel()
        label.numberOfLines = 0
        label.additionalLinkAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.red,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]

        let text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        label.text = text
        let firstLinkRange = text.range(of: "consectetur adipiscing elit")!
        label.addLink(withRange: firstLinkRange, accessibilityIdentifier: "first-link") {
            print("first link pressed")
        }

        let secondLinkRange = text.range(of: "minim veniam")!
        label.addLink(withRange: secondLinkRange, accessibilityIdentifier: "second-link") {
            print("second link pressed")
        }

        return label
    }
}
